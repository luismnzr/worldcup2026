class Product < ApplicationRecord
  KINDS = %w[physical digital].freeze

  has_many :order_items, dependent: :restrict_with_error
  has_one_attached :image
  has_one_attached :digital_asset

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :stock_quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :shipping_cost, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :kind, inclusion: { in: KINDS }
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9\-]+\z/, message: "solo letras minúsculas, números y guiones" }
  validates :sku, uniqueness: { allow_blank: true }

  before_validation :generate_slug, if: -> { slug.blank? && name.present? }

  scope :active, -> { where(active: true) }
  scope :in_stock, -> { where("stock_quantity > 0") }
  scope :physical, -> { where(kind: "physical") }
  scope :digital, -> { where(kind: "digital") }

  def physical?
    kind == "physical"
  end

  def digital?
    kind == "digital"
  end

  def to_param
    slug.presence || id.to_s
  end

  private

  def generate_slug
    base = name.to_s.parameterize
    candidate = base
    counter = 2
    while self.class.where.not(id: id).exists?(slug: candidate)
      candidate = "#{base}-#{counter}"
      counter += 1
    end
    self.slug = candidate
  end
end
