# Toma el payload de football-data.org y aplica los resultados FINALIZADOS a
# nuestros Match, reutilizando MatchResultService (puntos + propagación +
# broadcast). Mapea por el par de equipos (tolerante a inglés/acentos vía
# CountryFlags). Idempotente y no-destructivo: nunca pisa un partido que el
# admin ya cerró (override manual gana).
class ResultsSyncService
  Summary = Struct.new(:applied, :skipped, :unresolved, keyword_init: true)

  class << self
    def call(payload)
      fixtures = payload.is_a?(Hash) ? payload["matches"] : payload
      summary = Summary.new(applied: [], skipped: 0, unresolved: [])
      return summary unless fixtures.is_a?(Array)

      # Solo partidos con equipos ya conocidos en nuestra DB y sin cerrar.
      open_matches = Match.where.not(home_team: nil).where.not(away_team: nil)
                          .where.not(status: "finished").to_a

      fixtures.each { |fx| process(fx, open_matches, summary) }
      summary
    end

    private

    def process(fixture, open_matches, summary)
      return if fixture["status"] != "FINISHED"
      return if fixture["stage"] == "GROUP_STAGE"

      home = CountryFlags.canonical(fixture.dig("homeTeam", "name"))
      away = CountryFlags.canonical(fixture.dig("awayTeam", "name"))
      winner_side = fixture.dig("score", "winner")

      if home.blank? || away.blank?
        summary.unresolved << [ fixture.dig("homeTeam", "name"), fixture.dig("awayTeam", "name") ]
        return
      end
      return unless %w[HOME_TEAM AWAY_TEAM].include?(winner_side)

      match = find_match(open_matches, home, away)
      return unless match

      winner_name = winner_side == "HOME_TEAM" ? home : away
      advancing = same?(match.home_team, winner_name) ? match.home_team : match.away_team

      fh = fixture.dig("score", "fullTime", "home")
      fa = fixture.dig("score", "fullTime", "away")
      # Orienta el marcador a nuestro home/away (la API puede traerlo invertido).
      home_score, away_score = same?(match.home_team, home) ? [ fh, fa ] : [ fa, fh ]

      MatchResultService.record!(match, home_score: home_score, away_score: away_score, advancing_team: advancing)
      open_matches.delete(match)
      summary.applied << match.number
    rescue MatchResultService::InvalidResult => e
      Rails.logger.warn "[ResultsSync] P#{match&.number}: #{e.message}"
      summary.skipped += 1
    end

    # Empareja por el conjunto {local, visitante} sin importar el orden.
    def find_match(matches, home, away)
      matches.find do |m|
        pair = [ CountryFlags.canonical(m.home_team), CountryFlags.canonical(m.away_team) ]
        pair.include?(home) && pair.include?(away)
      end
    end

    def same?(team, canonical_name)
      CountryFlags.canonical(team) == canonical_name
    end
  end
end
