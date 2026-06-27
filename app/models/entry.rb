class Entry < ApplicationRecord
  belongs_to :user
  belongs_to :tournament
  has_many :payments, as: :payable, dependent: :nullify

  enum :status, { pending: 0, paid: 1 }

  validates :user_id, uniqueness: { scope: :tournament_id }

  scope :paid, -> { where(status: :paid) }

  # Marca la inscripción como pagada (idempotente). La fuente de verdad es el
  # webhook de Stripe; el admin tiene además un toggle manual de fallback.
  def mark_paid!(checkout_session_id: nil, amount: nil)
    return self if paid?

    update!(
      status: :paid,
      paid_at: Time.current,
      stripe_checkout_session_id: stripe_checkout_session_id || checkout_session_id,
      amount: amount || self.amount || tournament.entry_fee
    )
    self
  end
end
