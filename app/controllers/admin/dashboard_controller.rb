module Admin
  class DashboardController < BaseController
    skip_after_action :verify_authorized
    skip_after_action :verify_policy_scoped

    def show
      @total_students = User.students.count
      @active_subscriptions = UserSubscription.where(status: "active").count
      @upcoming_events = Event.published.where("date >= ?", Date.current).order(:date).limit(5)

      @orders_this_month = Order.where("created_at >= ?", Date.current.beginning_of_month).count
      @revenue_this_month = Payment.succeeded
                                   .where("created_at >= ?", Date.current.beginning_of_month)
                                   .sum(:amount)

      @recent_orders = Order.includes(:user).order(created_at: :desc).limit(10)
    end
  end
end
