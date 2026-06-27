class MemberPost < ApplicationRecord
  has_one_attached :cover_image

  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true,
            format: { with: /\A[a-z0-9\-]+\z/, message: "solo letras minúsculas, números y guiones" }

  before_validation :generate_slug, if: -> { slug.blank? && title.present? }

  scope :published, -> { where("published_at IS NOT NULL AND published_at <= ?", Time.current) }
  scope :ordered, -> { order(published_at: :desc, created_at: :desc) }

  def published?
    published_at.present? && published_at <= Time.current
  end

  def to_param
    slug.presence || id.to_s
  end

  private

  def generate_slug
    base = title.to_s.parameterize
    candidate = base
    counter = 2
    while self.class.where.not(id: id).exists?(slug: candidate)
      candidate = "#{base}-#{counter}"
      counter += 1
    end
    self.slug = candidate
  end
end
