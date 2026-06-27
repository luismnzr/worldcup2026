class ProfilesController < ApplicationController
  before_action :authenticate_user!
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def show
    @user = current_user
    @recent_orders = current_user.orders.recent.limit(3)
    @upcoming_events = current_user.event_registrations
                                   .where.not(status: "cancelled")
                                   .joins(:event)
                                   .where("events.date >= ?", Date.current)
                                   .includes(:event)
                                   .order("events.date ASC")
                                   .limit(3)
  end

  def subscription
    @user_subscription = current_user.user_subscription
  end

  def billing
    @payments = current_user.payments.recent.limit(20)
  end

  def orders
    @orders = current_user.orders.includes(order_items: :product).recent
  end

  def order
    @order = current_user.orders.includes(order_items: :product).find(params[:id])
  end

  def events
    @upcoming_registrations = current_user.event_registrations
                                          .where.not(status: "cancelled")
                                          .joins(:event)
                                          .where("events.date >= ?", Date.current)
                                          .includes(:event)
                                          .order("events.date ASC")

    @past_registrations = current_user.event_registrations
                                      .joins(:event)
                                      .where("events.date < ?", Date.current)
                                      .includes(:event)
                                      .order("events.date DESC")
                                      .limit(20)
  end
end
