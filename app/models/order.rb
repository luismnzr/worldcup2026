class Order < ApplicationRecord
  include AdminNotifiable

  SHIPPING_STATUSES = %w[unfulfilled fulfilled shipped delivered].freeze

  belongs_to :user, optional: true
  belongs_to :promotion_code, optional: true
  has_many :order_items, dependent: :destroy
  has_many :payments, as: :payable, dependent: :nullify
  accepts_nested_attributes_for :order_items, reject_if: :all_blank

  validates :total, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :subtotal, :shipping_cost, :discount_total, numericality: { greater_than_or_equal_to: 0 }
  validates :status, presence: true, inclusion: { in: %w[pending completed cancelled] }
  validates :payment_method, presence: true, inclusion: { in: %w[cash card stripe] }
  validates :shipping_status, presence: true, inclusion: { in: SHIPPING_STATUSES }

  scope :completed, -> { where(status: "completed") }
  scope :recent, -> { order(created_at: :desc) }

  after_create_commit :notify_admin_order_placed, if: -> { status == "completed" }

  def calculate_subtotal!
    self.subtotal = order_items.sum { |item| item.quantity * item.unit_price }
  end

  def calculate_total!
    calculate_subtotal!
    self.total = [ subtotal + shipping_cost.to_d - discount_total.to_d, 0 ].max
  end

  def requires_shipping?
    order_items.any? { |item| item.product&.physical? }
  end

  def shipping_address_lines
    [
      shipping_name,
      shipping_address_line1,
      shipping_address_line2,
      [ shipping_city, shipping_state, shipping_postal_code ].compact_blank.join(", ").presence,
      shipping_country
    ].compact_blank
  end

  def fulfilled?
    %w[fulfilled shipped delivered].include?(shipping_status)
  end

  private

  def notify_admin_order_placed
    customer = user&.full_name || email.presence || "Invitado"
    create_admin_notification(
      title: "Nuevo pedido ##{id}",
      body: "#{customer} compró por #{ActionController::Base.helpers.number_to_currency(total)}.",
      category: "order",
      action_url: "/admin/orders/#{id}"
    )
  end
end
