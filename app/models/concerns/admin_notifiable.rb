module AdminNotifiable
  extend ActiveSupport::Concern

  private

  def create_admin_notification(title:, body: nil, category:, action_url: nil)
    AdminNotification.create!(
      title: title,
      body: body,
      category: category,
      action_url: action_url
    )
  rescue => e
    Rails.logger.error("Failed to create admin notification: #{e.message}")
  end
end
