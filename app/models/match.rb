class Match < ApplicationRecord
  STAGES = %w[r32 r16 qf sf third final].freeze

  # Puntos por ronda — peso para que el título no se decida solo en R32.
  POINTS_BY_STAGE = {
    "r32"   => 1,
    "r16"   => 2,
    "qf"    => 3,
    "sf"    => 5,
    "third" => 3,
    "final" => 8
  }.freeze

  has_many :predictions, dependent: :destroy

  validates :number, presence: true, uniqueness: true
  validates :stage, presence: true, inclusion: { in: STAGES }
  validates :status, presence: true, inclusion: { in: %w[scheduled live finished] }

  scope :ordered, -> { order(:kickoff_at, :number) }
  scope :by_stage, ->(stage) { where(stage: stage) }
  scope :finished, -> { where(status: "finished") }

  # Un partido es predecible solo cuando ya conocemos a los dos equipos y el
  # silbatazo inicial sigue en el futuro.
  def teams_known?
    home_team.present? && away_team.present?
  end

  def predictable?
    teams_known? && kickoff_at.present? && kickoff_at.future?
  end

  # Las predicciones se bloquean en kickoff_at (UTC). Después no se crean ni editan.
  def locked?
    kickoff_at.blank? || kickoff_at.past?
  end

  def points_for_correct
    POINTS_BY_STAGE.fetch(stage, 0)
  end

  def teams
    [ home_team, away_team ].compact
  end

  # El otro equipo del partido dado uno de ellos (para propagar al perdedor).
  def other_team(team)
    return home_team if team == away_team
    return away_team if team == home_team

    nil
  end

  def display_home
    home_team.presence || home_label.presence || "Por definir"
  end

  def display_away
    away_team.presence || away_label.presence || "Por definir"
  end

  def stage_name
    {
      "r32" => "Dieciseisavos", "r16" => "Octavos", "qf" => "Cuartos",
      "sf" => "Semifinal", "third" => "Tercer lugar", "final" => "Final"
    }.fetch(stage, stage)
  end
end
