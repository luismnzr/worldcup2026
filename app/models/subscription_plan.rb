class SubscriptionPlan < ApplicationRecord
  # Supported billing intervals — keys are stored in the DB, values carry the
  # Spanish label for admin UIs, the noun used after "por" on the pricing card
  # ("por mes", "por año") and the Stripe recurring config (interval +
  # interval_count) used when creating the Stripe Price lazily.
  INTERVALS = {
    "weekly"      => { label: "Semanal",    noun: "semana",    stripe: { interval: "week",  interval_count: 1 } },
    "monthly"     => { label: "Mensual",    noun: "mes",       stripe: { interval: "month", interval_count: 1 } },
    "quarterly"   => { label: "Trimestral", noun: "trimestre", stripe: { interval: "month", interval_count: 3 } },
    "semi_annual" => { label: "Semestral",  noun: "semestre",  stripe: { interval: "month", interval_count: 6 } },
    "annual"      => { label: "Anual",      noun: "año",       stripe: { interval: "year",  interval_count: 1 } }
  }.freeze

  has_many :user_subscriptions, dependent: :restrict_with_error

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :interval, presence: true, inclusion: { in: INTERVALS.keys }

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:sort_order, :price) }

  def interval_label
    INTERVALS.dig(interval, :label) || interval.to_s.titleize
  end

  def interval_noun
    INTERVALS.dig(interval, :noun) || interval.to_s
  end

  def stripe_recurring
    INTERVALS.dig(interval, :stripe) || { interval: "month", interval_count: 1 }
  end

  # Bullet points rendered on the pricing card — stored as newline-separated
  # text so admins can edit them from a plain <textarea>.
  def features_list
    features.to_s.split("\n").map(&:strip).reject(&:blank?)
  end

  def features_list=(value)
    self.features = Array(value).map(&:to_s).map(&:strip).reject(&:blank?).join("\n")
  end
end
