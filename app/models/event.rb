class Event < ApplicationRecord
  has_many :event_registrations, dependent: :destroy
  has_many :registered_users, through: :event_registrations, source: :user
  has_one_attached :cover_image

  validates :title, presence: true
  validates :date, presence: true
  validates :capacity, numericality: { greater_than: 0 }, allow_nil: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  scope :published, -> { where(published: true) }
  scope :upcoming, -> { where("COALESCE(end_date, date) >= ?", Date.current).order(date: :asc, start_time: :asc) }
  scope :past, -> { where("COALESCE(end_date, date) < ?", Date.current).order(date: :desc) }

  def full?
    capacity.present? && spots_remaining.present? && spots_remaining <= 0
  end

  def confirmed_count
    event_registrations.where(status: "confirmed").count
  end

  def past?
    (end_date || date) < Date.current
  end

  def free?
    price.blank? || price.zero?
  end

  def paid?
    !free?
  end
end
