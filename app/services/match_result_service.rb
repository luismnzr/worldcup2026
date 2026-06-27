class MatchResultService
  class InvalidResult < StandardError; end

  class << self
    # Captura el resultado de un partido (lo hace el admin a mano):
    #   1. Guarda marcadores + advancing_team y lo marca como finished.
    #   2. Recalcula points_awarded de todas las predicciones del partido.
    #   3. Propaga el equipo al siguiente partido (abre la siguiente ronda).
    #   4. Hace broadcast del leaderboard por Turbo Streams.
    def record!(match, home_score:, away_score:, advancing_team:)
      advancing_team = advancing_team.to_s.strip
      validate!(match, advancing_team)

      ActiveRecord::Base.transaction do
        match.update!(
          home_score: home_score,
          away_score: away_score,
          advancing_team: advancing_team,
          status: "finished"
        )
        rescore(match)
        propagate(match)
      end

      LeaderboardService.broadcast(Tournament.current)
      match
    end

    # Recalcula los puntos de cada predicción del partido contra el resultado.
    def rescore(match)
      bonus = Tournament.current.exact_score_bonus
      match.predictions.includes(:match).find_each do |prediction|
        prediction.update_column(:points_awarded, prediction.computed_points(exact_score_bonus: bonus))
      end
    end

    # Propaga el ganador/perdedor de este partido a los partidos que lo usan como
    # fuente. "winner" => advancing_team, "loser" => el otro equipo.
    def propagate(match)
      loser = match.other_team(match.advancing_team)

      Match.where(home_source_number: match.number).find_each do |dependent|
        team = dependent.home_source_result == "loser" ? loser : match.advancing_team
        dependent.update!(home_team: team) if team.present?
      end

      Match.where(away_source_number: match.number).find_each do |dependent|
        team = dependent.away_source_result == "loser" ? loser : match.advancing_team
        dependent.update!(away_team: team) if team.present?
      end
    end

    private

    def validate!(match, advancing_team)
      raise InvalidResult, "Faltan los equipos del partido" unless match.teams_known?

      unless match.teams.include?(advancing_team)
        raise InvalidResult, "El equipo que avanza debe ser uno de los dos del partido"
      end
    end
  end
end
