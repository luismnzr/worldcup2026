class UserSubscription < ApplicationRecord
  include AdminNotifiable

  belongs_to :user
  belongs_to :subscription_plan

  validates :status, presence: true, inclusion: { in: %w[active past_due cancelled inactive] }

  scope :active, -> { where(status: "active") }

  after_create_commit :notify_admin_subscription_purchase

  def active?
    status == "active" && (current_period_end.nil? || current_period_end > Time.current)
  end

  def cancel!
    update!(status: "cancelled")
  end

  private

  def notify_admin_subscription_purchase
    create_admin_notification(
      title: "Nueva suscripción",
      body: "#{user.full_name} se suscribió al plan #{subscription_plan.name}",
      category: "subscription",
      action_url: "/admin/subscription_plans"
    )
  end
end
