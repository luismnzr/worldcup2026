class PromotionCode < ApplicationRecord
  DISCOUNT_TYPES = %w[percent_off amount_off].freeze
  APPLIES_TO = %w[all subscription product event].freeze

  has_many :orders, dependent: :nullify

  validates :code, presence: true, uniqueness: { case_sensitive: false }
  validates :discount_type, presence: true, inclusion: { in: DISCOUNT_TYPES }
  validates :discount_value, presence: true, numericality: { greater_than: 0 }
  validates :max_redemptions, numericality: { greater_than: 0 }, allow_nil: true
  validates :applies_to, presence: true, inclusion: { in: APPLIES_TO }

  validate :percent_off_max_100

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(created_at: :desc) }
  scope :for_subscription, -> { where(applies_to: %w[all subscription]) }
  scope :for_product, -> { where(applies_to: %w[all product]) }
  scope :for_event, -> { where(applies_to: %w[all event]) }

  before_validation :upcase_code

  def percent_off?
    discount_type == "percent_off"
  end

  def amount_off?
    discount_type == "amount_off"
  end

  def applies_to_label
    case applies_to
    when "all"          then "Todo"
    when "subscription" then "Suscripciones"
    when "product"      then "Productos"
    when "event"        then "Eventos"
    end
  end

  def applies_to?(scope)
    applies_to == "all" || applies_to == scope.to_s
  end

  def display_discount
    if percent_off?
      "#{discount_value.to_i}%"
    else
      ActionController::Base.helpers.number_to_currency(discount_value)
    end
  end

  def expired?
    expires_at.present? && expires_at < Time.current
  end

  def fully_redeemed?
    max_redemptions.present? && times_redeemed >= max_redemptions
  end

  def usable?
    active? && !expired? && !fully_redeemed?
  end

  private

  def upcase_code
    self.code = code&.upcase&.strip
  end

  def percent_off_max_100
    if percent_off? && discount_value.present? && discount_value > 100
      errors.add(:discount_value, "no puede ser mayor a 100 para descuento porcentual")
    end
  end
end
