class Tournament < ApplicationRecord
  has_many :entries, dependent: :destroy

  validates :name, presence: true
  validates :currency, presence: true
  validates :entry_fee, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :exact_score_bonus, numericality: { greater_than_or_equal_to: 0 }

  # Registro único de configuración. Lo creamos la primera vez con los defaults.
  def self.current
    first || create!
  end

  def paid_entries
    entries.paid
  end

  def participants_count
    paid_entries.count
  end
end
