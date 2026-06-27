class StripeWebhookService
  class << self
    def process(event)
      if StripeWebhookEvent.processed?(event.id)
        Rails.logger.info "Skipping already-processed Stripe event: #{event.id} (#{event.type})"
        return
      end

      case event.type
      when "checkout.session.completed"
        handle_checkout_completed(event.data.object)
      when "invoice.paid"
        handle_invoice_paid(event.data.object)
      when "invoice.payment_failed"
        handle_invoice_payment_failed(event.data.object)
      when "customer.subscription.updated"
        handle_subscription_updated(event.data.object)
      when "customer.subscription.deleted"
        handle_subscription_deleted(event.data.object)
      else
        Rails.logger.info "Unhandled Stripe event: #{event.type}"
        return
      end

      StripeWebhookEvent.record!(event.id, event.type)
    rescue ActiveRecord::RecordNotUnique
      Rails.logger.info "Stripe event #{event.id} was processed concurrently, skipping"
    end

    private

    def handle_checkout_completed(session)
      metadata = session.metadata

      case metadata["type"]
      when "subscription"
        fulfill_subscription(session, metadata)
      when "product"
        fulfill_product(session, metadata)
      when "entry"
        fulfill_entry(session, metadata)
      end
    end

    # Inscripción a la quiniela: marca el Entry como paid (esto desbloquea
    # predicciones y leaderboard) y registra el Payment. Idempotente.
    def fulfill_entry(session, metadata)
      return if Payment.exists?(stripe_checkout_session_id: session.id)

      entry = Entry.find(metadata["entry_id"])
      currency = session.currency.presence || entry.tournament.currency
      amount = session.amount_total ? cents_to_decimal(session.amount_total) : entry.tournament.entry_fee

      ActiveRecord::Base.transaction do
        entry.mark_paid!(checkout_session_id: session.id, amount: amount)

        Payment.create!(
          user: entry.user,
          stripe_checkout_session_id: session.id,
          stripe_payment_intent_id: session.payment_intent,
          amount: amount,
          currency: currency,
          status: "succeeded",
          payment_method: "stripe",
          description: "Inscripción — #{entry.tournament.name}",
          payable: entry
        )
      end

      LeaderboardService.broadcast(entry.tournament)
    end

    def fulfill_subscription(session, metadata)
      user = User.find(metadata["user_id"])
      plan = SubscriptionPlan.find(metadata["subscription_plan_id"])

      stripe_subscription = Stripe::Subscription.retrieve(session.subscription)

      currency = session.currency.presence || StudioSetting.currency

      user_sub = nil
      ActiveRecord::Base.transaction do
        user_sub = user.user_subscription || user.build_user_subscription
        user_sub.update!(
          subscription_plan: plan,
          stripe_subscription_id: stripe_subscription.id,
          stripe_customer_id: session.customer,
          status: "active",
          current_period_start: Time.at(sub_period(stripe_subscription).current_period_start),
          current_period_end: Time.at(sub_period(stripe_subscription).current_period_end)
        )

        user.payments.create!(
          stripe_checkout_session_id: session.id,
          amount: plan.price,
          currency: currency,
          status: "succeeded",
          payment_method: "stripe",
          description: "Subscription: #{plan.name}",
          payable: user_sub
        )
      end

      SubscriptionMailer.confirmed(user_sub).deliver_later
    end

    def fulfill_product(session, metadata)
      return if Order.exists?(stripe_checkout_session_id: session.id)

      user = User.find(metadata["user_id"])
      product = Product.find(metadata["product_id"])

      currency = session.currency.presence || StudioSetting.currency
      shipping_amount = (session.respond_to?(:shipping_cost) && session.shipping_cost) ? cents_to_decimal(session.shipping_cost.amount_total) : 0.to_d
      discount_amount = session.total_details ? cents_to_decimal(session.total_details.amount_discount.to_i) : 0.to_d
      subtotal_amount = session.amount_subtotal ? cents_to_decimal(session.amount_subtotal) : product.price
      total_amount    = session.amount_total ? cents_to_decimal(session.amount_total) : product.price

      shipping_details = session.respond_to?(:shipping_details) ? session.shipping_details : nil
      address = shipping_details&.address

      promo = lookup_promotion_code(session)

      order = nil
      ActiveRecord::Base.transaction do
        order = Order.create!(
          user: user,
          email: session.customer_details&.email || user.email,
          phone: session.customer_details&.phone,
          status: "completed",
          payment_method: "stripe",
          stripe_payment_intent_id: session.payment_intent,
          stripe_checkout_session_id: session.id,
          subtotal: subtotal_amount,
          shipping_cost: shipping_amount,
          discount_total: discount_amount,
          total: total_amount,
          promotion_code: promo,
          shipping_status: product.physical? ? "unfulfilled" : "fulfilled",
          shipping_name: shipping_details&.name,
          shipping_address_line1: address&.line1,
          shipping_address_line2: address&.line2,
          shipping_city: address&.city,
          shipping_state: address&.state,
          shipping_postal_code: address&.postal_code,
          shipping_country: address&.country
        )

        order.order_items.create!(
          product: product,
          quantity: 1,
          unit_price: product.price
        )

        if product.stock_quantity.positive?
          product.with_lock do
            new_stock = [ product.stock_quantity - 1, 0 ].max
            product.update_columns(stock_quantity: new_stock)
          end
        end

        if promo
          PromotionCode.where(id: promo.id).update_all("times_redeemed = times_redeemed + 1")
        end

        Payment.create!(
          user: user,
          stripe_checkout_session_id: session.id,
          stripe_payment_intent_id: session.payment_intent,
          amount: total_amount,
          currency: currency,
          status: "succeeded",
          payment_method: "stripe",
          description: "Pedido — #{product.name}",
          payable: order
        )
      end

      OrderMailer.confirmation(order).deliver_later
    end

    def handle_invoice_paid(invoice)
      return if invoice.billing_reason == "subscription_create"

      subscription_id = invoice.subscription
      return unless subscription_id

      user_sub = UserSubscription.find_by(stripe_subscription_id: subscription_id)
      return unless user_sub

      user_sub.update!(
        status: "active",
        current_period_start: Time.at(invoice.period_start),
        current_period_end: Time.at(invoice.period_end)
      )

      payment_intent_id = invoice.payments&.data&.first&.payment&.payment_intent

      user_sub.user.payments.create!(
        stripe_payment_intent_id: payment_intent_id,
        amount: invoice.amount_paid / 100.0,
        currency: invoice.currency,
        status: "succeeded",
        payment_method: "stripe",
        description: "Subscription renewal: #{user_sub.subscription_plan.name}",
        payable: user_sub
      )
    end

    def handle_invoice_payment_failed(invoice)
      subscription_id = invoice.subscription
      return unless subscription_id

      user_sub = UserSubscription.find_by(stripe_subscription_id: subscription_id)
      return unless user_sub

      user_sub.update!(status: "past_due")

      SubscriptionMailer.renewal_failed(user_sub).deliver_later
    end

    def handle_subscription_updated(subscription)
      user_sub = UserSubscription.find_by(stripe_subscription_id: subscription.id)
      return unless user_sub

      status = case subscription.status
      when "active" then "active"
      when "past_due" then "past_due"
      when "canceled", "unpaid" then "cancelled"
      else "inactive"
      end

      user_sub.update!(
        status: status,
        current_period_start: Time.at(sub_period(subscription).current_period_start),
        current_period_end: Time.at(sub_period(subscription).current_period_end)
      )
    end

    def handle_subscription_deleted(subscription)
      user_sub = UserSubscription.find_by(stripe_subscription_id: subscription.id)
      return unless user_sub

      user_sub.update!(status: "cancelled")
    end

    def sub_period(subscription)
      subscription.items.data.first
    end

    def cents_to_decimal(cents)
      (cents.to_d / 100).round(2)
    end

    def lookup_promotion_code(session)
      return nil unless session.respond_to?(:total_details)
      breakdown = session.total_details&.breakdown
      stripe_promo_id = breakdown && breakdown.discounts.is_a?(Array) ? breakdown.discounts.first&.discount&.promotion_code : nil
      return nil if stripe_promo_id.blank?

      PromotionCode.find_by(stripe_promotion_code_id: stripe_promo_id)
    end
  end
end
