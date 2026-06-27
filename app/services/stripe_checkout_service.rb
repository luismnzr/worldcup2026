class StripeCheckoutService
  class << self
    def create_subscription_session(user:, plan:, success_url:, cancel_url:)
      customer_id = StripeCustomerService.find_or_create(user)
      ensure_stripe_price(plan) if plan.stripe_price_id.blank?

      Stripe::Checkout::Session.create(
        customer: customer_id,
        mode: "subscription",
        allow_promotion_codes: true,
        line_items: [ {
          price: plan.stripe_price_id,
          quantity: 1
        } ],
        metadata: {
          type: "subscription",
          subscription_plan_id: plan.id,
          user_id: user.id
        },
        success_url: success_url,
        cancel_url: cancel_url
      )
    end

    def create_product_session(user:, product:, success_url:, cancel_url:)
      customer_id = StripeCustomerService.find_or_create(user)
      currency = StudioSetting.currency

      session_params = {
        customer: customer_id,
        mode: "payment",
        allow_promotion_codes: true,
        line_items: [ {
          price_data: {
            currency: currency,
            unit_amount: cents(product.price),
            product_data: {
              name: product.name,
              description: product.description.to_s.truncate(500).presence
            }.compact
          },
          quantity: 1
        } ],
        metadata: {
          type: "product",
          product_id: product.id,
          user_id: user.id
        },
        success_url: success_url,
        cancel_url: cancel_url
      }

      if product.physical? && product.requires_shipping?
        session_params[:shipping_address_collection] = { allowed_countries: shipping_countries }
        session_params[:phone_number_collection] = { enabled: true }

        if product.shipping_cost.to_d.positive?
          session_params[:shipping_options] = [ {
            shipping_rate_data: {
              type: "fixed_amount",
              display_name: "Envío",
              fixed_amount: { amount: cents(product.shipping_cost), currency: currency }
            }
          } ]
        end
      end

      Stripe::Checkout::Session.create(session_params)
    end

    # Inscripción al torneo — cargo único por ACCESO/servicio (no es un boleto a
    # un bote de premios). Marca el Entry como paid vía webhook.
    def create_entry_session(user:, tournament:, entry:, success_url:, cancel_url:)
      customer_id = StripeCustomerService.find_or_create(user)
      currency = tournament.currency.downcase

      Stripe::Checkout::Session.create(
        customer: customer_id,
        mode: "payment",
        line_items: [ {
          price_data: {
            currency: currency,
            unit_amount: cents(tournament.entry_fee),
            product_data: {
              name: "Inscripción — #{tournament.name}",
              description: "Acceso al torneo de predicciones."
            }
          },
          quantity: 1
        } ],
        metadata: {
          type: "entry",
          entry_id: entry.id,
          tournament_id: tournament.id,
          user_id: user.id
        },
        success_url: success_url,
        cancel_url: cancel_url
      )
    end

    def create_portal_session(user:, return_url:)
      raise "User has no Stripe customer ID" if user.stripe_customer_id.blank?

      Stripe::BillingPortal::Session.create(
        customer: user.stripe_customer_id,
        return_url: return_url
      )
    end

    private

    def cents(amount)
      (amount.to_d * 100).to_i
    end

    def shipping_countries
      %w[MX US CA]
    end

    def ensure_stripe_price(plan)
      currency = StudioSetting.currency

      product = Stripe::Product.create(
        name: plan.name,
        description: plan.description.presence || plan.name
      )

      price = Stripe::Price.create(
        product: product.id,
        unit_amount: cents(plan.price),
        currency: currency,
        recurring: plan.stripe_recurring
      )

      plan.update!(stripe_price_id: price.id)
    end
  end
end
