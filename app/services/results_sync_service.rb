# Espejea el cuadro de eliminación desde football-data.org hacia nuestros Match.
#
# Estrategia: cada partido nuestro guarda el `id` de football-data (external_id).
# La primera vez se asigna emparejando, por etapa, los fixtures de la API
# (ordenados por fecha) con nuestros slots (ordenados por número). De ahí en
# adelante el id es la llave estable. Sincroniza equipos, fecha y marcadores;
# la sede (venue) se respeta tal cual (la API gratis no la trae). No pisa un
# partido ya cerrado (override manual / idempotencia).
class ResultsSyncService
  Summary = Struct.new(:applied, :filled, :unresolved, keyword_init: true)

  STAGE_MAP = {
    "LAST_32" => "r32", "LAST_16" => "r16", "QUARTER_FINALS" => "qf",
    "SEMI_FINALS" => "sf", "THIRD_PLACE" => "third", "FINAL" => "final"
  }.freeze

  Fixture = Struct.new(:external_id, :stage, :kickoff, :status, :home, :away, :fh, :fa, :winner, keyword_init: true)

  class << self
    def call(payload)
      summary = Summary.new(applied: [], filled: [], unresolved: [])
      fixtures = parse(payload)
      return summary if fixtures.empty?

      assign_external_ids(fixtures)

      # La API es la fuente de verdad: re-aplica a TODOS los partidos en cada
      # sync (con detección de cambios). Si un resultado finalizado cambió,
      # recalcula sus puntos.
      rescore = []
      fixtures.each do |fx|
        match = Match.find_by(external_id: fx.external_id)
        next unless match

        if apply!(match, fx, summary) # devuelve true si cambió y quedó finalizado con avance
          rescore << match
        end
      end

      rescore.each { |m| MatchResultService.rescore(m) }
      LeaderboardService.broadcast(Tournament.current) if rescore.any?
      summary
    end

    private

    def parse(payload)
      rows = payload.is_a?(Hash) ? payload["matches"] : payload
      return [] unless rows.is_a?(Array)

      rows.filter_map do |m|
        stage = STAGE_MAP[m["stage"]]
        next unless stage # ignora fase de grupos

        Fixture.new(
          external_id: m["id"],
          stage: stage,
          kickoff: parse_time(m["utcDate"]),
          status: map_status(m["status"]),
          home: resolve_name(m.dig("homeTeam", "name")),
          away: resolve_name(m.dig("awayTeam", "name")),
          fh: m.dig("score", "fullTime", "home"),
          fa: m.dig("score", "fullTime", "away"),
          winner: m.dig("score", "winner")
        )
      end
    end

    # Asigna external_id a nuestros slots la primera vez (por etapa: fixtures por
    # fecha ↔ nuestros partidos por número).
    def assign_external_ids(fixtures)
      fixtures.group_by(&:stage).each do |stage, fxs|
        pending = fxs.reject { |fx| Match.exists?(external_id: fx.external_id) }
                     .sort_by { |fx| fx.kickoff || Time.zone.at(0) }
        slots = Match.where(stage: stage, external_id: nil).order(:number).to_a

        pending.zip(slots).each do |fx, slot|
          slot&.update_columns(external_id: fx.external_id)
        end
      end
    end

    # Aplica el fixture al partido. Solo guarda si algo cambió. Devuelve true si
    # tras el cambio quedó finalizado con equipo que avanza (para recalcular).
    def apply!(match, fx, summary)
      match.kickoff_at = fx.kickoff if fx.kickoff
      match.home_team = fx.home if fx.home.present?
      match.away_team = fx.away if fx.away.present?
      match.status = fx.status
      match.home_score = fx.fh
      match.away_score = fx.fa

      if fx.status == "finished" && %w[HOME_TEAM AWAY_TEAM].include?(fx.winner)
        match.advancing_team = fx.winner == "HOME_TEAM" ? match.home_team : match.away_team
      end

      changed = match.changed?
      match.save! if changed

      summary.filled << match.number if match.home_team.present? && match.away_team.present?
      finished_with_winner = match.status == "finished" && match.advancing_team.present?
      summary.applied << match.number if changed && finished_with_winner
      changed && finished_with_winner
    end

    def resolve_name(raw)
      return nil if raw.blank?

      CountryFlags.canonical(raw) || raw
    end

    def map_status(status)
      case status
      when "IN_PLAY", "PAUSED" then "live"
      when "FINISHED" then "finished"
      else "scheduled"
      end
    end

    def parse_time(iso)
      Time.zone.parse(iso.to_s)
    rescue ArgumentError, TypeError
      nil
    end
  end
end
