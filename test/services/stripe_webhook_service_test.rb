require "test_helper"
require "ostruct"
require "minitest/mock"

class StripeWebhookServiceTest < ActiveSupport::TestCase
  setup do
    @user = create(:user, stripe_customer_id: "cus_test123")
    @plan = create(:subscription_plan, name: "Monthly", price: 1800, stripe_price_id: "price_test123")
  end

  test "fulfill_subscription creates user_subscription and payment" do
    sub_item = OpenStruct.new(
      current_period_start: 1.day.ago.to_i,
      current_period_end: 30.days.from_now.to_i
    )
    stripe_sub = OpenStruct.new(
      id: "sub_test123",
      latest_invoice: "in_test123",
      items: OpenStruct.new(data: [ sub_item ])
    )

    session = OpenStruct.new(
      id: "cs_test_session_sub",
      payment_intent: nil,
      subscription: "sub_test123",
      customer: "cus_test123",
      currency: "mxn",
      metadata: {
        "type" => "subscription",
        "subscription_plan_id" => @plan.id.to_s,
        "user_id" => @user.id.to_s
      }
    )

    event = OpenStruct.new(
      id: "evt_#{SecureRandom.hex(8)}",
      type: "checkout.session.completed",
      data: OpenStruct.new(object: session)
    )

    mock = Minitest::Mock.new
    mock.expect :call, stripe_sub, [ "sub_test123" ]

    Stripe::Subscription.stub(:retrieve, mock) do
      assert_difference -> { UserSubscription.count } => 1, -> { Payment.count } => 1 do
        StripeWebhookService.process(event)
      end

      user_sub = @user.reload.user_subscription
      assert_equal "active", user_sub.status
      assert_equal "sub_test123", user_sub.stripe_subscription_id
      assert_equal @plan, user_sub.subscription_plan
    end
  end

  test "handle_subscription_deleted cancels subscription" do
    user_sub = create(:user_subscription, user: @user, subscription_plan: @plan,
                      stripe_subscription_id: "sub_to_cancel", status: "active")

    subscription_obj = OpenStruct.new(
      id: "sub_to_cancel",
      status: "canceled"
    )

    event = OpenStruct.new(
      id: "evt_#{SecureRandom.hex(8)}",
      type: "customer.subscription.deleted",
      data: OpenStruct.new(object: subscription_obj)
    )

    StripeWebhookService.process(event)

    assert_equal "cancelled", user_sub.reload.status
  end

  test "fulfill_product creates order, order item, payment and decrements stock" do
    product = create(:product, price: 250, stock_quantity: 5, shipping_cost: 50)

    session = OpenStruct.new(
      id: "cs_test_session_prod",
      payment_intent: "pi_test_prod",
      currency: "mxn",
      amount_subtotal: 25000,
      amount_total: 30000,
      total_details: OpenStruct.new(amount_discount: 0, breakdown: nil),
      shipping_cost: OpenStruct.new(amount_total: 5000),
      shipping_details: OpenStruct.new(
        name: "Test Buyer",
        address: OpenStruct.new(
          line1: "Calle Falsa 123",
          line2: nil,
          city: "CDMX",
          state: "CDMX",
          postal_code: "01000",
          country: "MX"
        )
      ),
      customer_details: OpenStruct.new(email: "buyer@example.com", phone: "5551234567"),
      metadata: {
        "type" => "product",
        "product_id" => product.id.to_s,
        "user_id" => @user.id.to_s
      }
    )

    event = OpenStruct.new(
      id: "evt_#{SecureRandom.hex(8)}",
      type: "checkout.session.completed",
      data: OpenStruct.new(object: session)
    )

    assert_difference -> { Order.count } => 1, -> { OrderItem.count } => 1, -> { Payment.count } => 1 do
      StripeWebhookService.process(event)
    end

    order = Order.last
    assert_equal "completed", order.status
    assert_equal "stripe", order.payment_method
    assert_equal "unfulfilled", order.shipping_status
    assert_equal 250, order.subtotal.to_f
    assert_equal 50, order.shipping_cost.to_f
    assert_equal 300, order.total.to_f
    assert_equal "Test Buyer", order.shipping_name
    assert_equal "Calle Falsa 123", order.shipping_address_line1
    assert_equal product, order.order_items.first.product
    assert_equal 4, product.reload.stock_quantity
  end

  test "fulfill_product is idempotent for the same checkout session" do
    product = create(:product, price: 100, stock_quantity: 3)

    session = OpenStruct.new(
      id: "cs_dup_session",
      payment_intent: "pi_dup",
      currency: "mxn",
      amount_subtotal: 10000,
      amount_total: 10000,
      total_details: OpenStruct.new(amount_discount: 0, breakdown: nil),
      shipping_cost: nil,
      shipping_details: nil,
      customer_details: OpenStruct.new(email: "buyer@example.com", phone: nil),
      metadata: {
        "type" => "product",
        "product_id" => product.id.to_s,
        "user_id" => @user.id.to_s
      }
    )

    event = OpenStruct.new(
      id: "evt_#{SecureRandom.hex(8)}",
      type: "checkout.session.completed",
      data: OpenStruct.new(object: session)
    )

    StripeWebhookService.process(event)

    duplicate_event = OpenStruct.new(
      id: "evt_#{SecureRandom.hex(8)}",
      type: "checkout.session.completed",
      data: OpenStruct.new(object: session)
    )

    assert_no_difference [ "Order.count", "OrderItem.count", "Payment.count" ] do
      StripeWebhookService.process(duplicate_event)
    end
  end

  test "handle_invoice_payment_failed marks subscription as past_due" do
    user_sub = create(:user_subscription, user: @user, subscription_plan: @plan,
                      stripe_subscription_id: "sub_pastdue", status: "active")

    invoice = OpenStruct.new(
      subscription: "sub_pastdue",
      payment_intent: "pi_failed"
    )

    event = OpenStruct.new(
      id: "evt_#{SecureRandom.hex(8)}",
      type: "invoice.payment_failed",
      data: OpenStruct.new(object: invoice)
    )

    StripeWebhookService.process(event)

    assert_equal "past_due", user_sub.reload.status
  end
end
