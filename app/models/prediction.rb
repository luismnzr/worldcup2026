class Prediction < ApplicationRecord
  belongs_to :user
  belongs_to :match

  validates :user_id, uniqueness: { scope: :match_id }
  validates :advancing_pick, presence: true
  validate :pick_is_one_of_the_teams
  validate :match_open_for_picks, on: :create
  validate :match_not_locked_on_pick_change, on: :update

  scope :for_match, ->(match) { where(match: match) }

  # Bonus de marcador exacto: el usuario predijo ambos marcadores.
  def predicted_score?
    home_score.present? && away_score.present?
  end

  def exact_score_hit?
    predicted_score? &&
      match.home_score.present? && match.away_score.present? &&
      home_score == match.home_score && away_score == match.away_score
  end

  def correct?
    match.advancing_team.present? && advancing_pick == match.advancing_team
  end

  # Calcula los puntos que merece esta predicción según el resultado actual del
  # partido. No persiste — eso lo hace ScoringService dentro de su transacción.
  def computed_points(exact_score_bonus: 0)
    return 0 unless correct?

    points = match.points_for_correct
    points += exact_score_bonus if exact_score_hit?
    points
  end

  private

  def pick_is_one_of_the_teams
    return if advancing_pick.blank?
    return unless match&.teams_known?
    return if match.teams.include?(advancing_pick)

    errors.add(:advancing_pick, "debe ser uno de los equipos del partido")
  end

  def match_open_for_picks
    return if match&.predictable?

    errors.add(:base, "Este partido aún no está abierto para predicciones")
  end

  # En update solo bloqueamos si el usuario cambia su pick/marcador; el recálculo
  # de points_awarded tras un resultado debe poder guardarse aunque esté locked.
  def match_not_locked_on_pick_change
    return unless will_save_change_to_advancing_pick? ||
                  will_save_change_to_home_score? ||
                  will_save_change_to_away_score?
    return unless match&.locked?

    errors.add(:base, "Las predicciones de este partido ya están cerradas")
  end
end
