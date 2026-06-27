module Admin
  class NotificationsController < BaseController
    def index
      @notifications = policy_scope(AdminNotification).recent.limit(50)
      @unread_count = AdminNotification.unread.count
    end

    def mark_as_read
      authorize AdminNotification, :mark_as_read?
      AdminNotification.unread.update_all(read_at: Time.current)
      redirect_to admin_notifications_path, notice: "Todas las notificaciones marcadas como leídas."
    end

    def mark_one_read
      notification = AdminNotification.find(params[:id])
      authorize notification, :mark_one_read?
      notification.mark_as_read!
      redirect_to notification.action_url || admin_notifications_path
    end
  end
end
