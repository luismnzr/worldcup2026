class AdminNotification < ApplicationRecord
  CATEGORIES = %w[new_user subscription order].freeze

  validates :title, presence: true
  validates :category, presence: true, inclusion: { in: CATEGORIES }

  scope :unread, -> { where(read_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  def read?
    read_at.present?
  end

  def mark_as_read!
    update!(read_at: Time.current) unless read?
  end

  def icon_class
    case category
    when "new_user"     then "text-[var(--color-success)]"
    when "subscription" then "text-[var(--color-primary)]"
    when "order"        then "text-[var(--color-warning)]"
    else "text-[var(--color-muted-foreground)]"
    end
  end
end
