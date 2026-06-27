class EventRegistration < ApplicationRecord
  belongs_to :event
  belongs_to :user

  validates :status, presence: true, inclusion: { in: %w[confirmed cancelled] }
  validates :user_id, uniqueness: {
    scope: :event_id,
    conditions: -> { where.not(status: "cancelled") },
    message: "ya está registrado en este evento"
  }

  scope :confirmed, -> { where(status: "confirmed") }

  def cancel!
    update!(status: "cancelled", cancelled_at: Time.current)
  end
end
