module BracketHelper
  STAGE_LABELS = {
    "r32" => "Dieciseisavos",
    "r16" => "Octavos",
    "qf"  => "Cuartos",
    "sf"  => "Semifinales",
    "final" => "Final",
    "third" => "Tercer lugar"
  }.freeze

  MONTHS_ES = %w[ene feb mar abr may jun jul ago sep oct nov dic].freeze

  # Rango de fechas de una ronda, p. ej. "28 jun – 4 jul". Espera el hash
  # @matches (number => Match) ya cargado por el controller.
  def bracket_stage_dates(matches_by_number, stage)
    times = matches_by_number.values
                             .select { |m| m.stage == stage && m.kickoff_at.present? }
                             .map { |m| m.kickoff_at.in_time_zone(StudioSetting.studio_timezone) }
    return nil if times.empty?

    lo = short_day(times.min)
    hi = short_day(times.max)
    lo == hi ? lo : "#{lo} – #{hi}"
  end

  private

  def short_day(time)
    "#{time.day} #{MONTHS_ES[time.month - 1]}"
  end
end
