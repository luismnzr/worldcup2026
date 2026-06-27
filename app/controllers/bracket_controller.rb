class BracketController < ApplicationController
  include TournamentAccess

  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  TAB_STAGES = %w[r32 r16 qf sf final].freeze

  def show
    @matches = Match.ordered.index_by(&:number)
    @final = @matches.values.find { |m| m.stage == "final" }
    @third = @matches.values.find { |m| m.stage == "third" }
    @left, @right = build_sides

    @matches_by_stage = @matches.values.group_by(&:stage)
    @view = params[:view] == "todos" ? "todos" : "rondas"
    @active_stage = default_active_stage
  end

  private

  # Abre la pestaña en la primera ronda que aún tenga partidos por jugarse.
  def default_active_stage
    TAB_STAGES.find { |stage| (@matches_by_stage[stage] || []).any? { |m| m.status != "finished" } } || "final"
  end

  # Divide el árbol en dos mitades que convergen en la final, ordenadas
  # verticalmente. Cada mitad: { sf: [..], qf: [..], r16: [..], r32: [..] }.
  def build_sides
    return [ {}, {} ] unless @final

    [ side(@matches[@final.home_source_number]), side(@matches[@final.away_source_number]) ]
  end

  def side(sf)
    return {} unless sf

    qf  = feeders(sf)
    r16 = qf.flat_map { |m| feeders(m) }
    r32 = r16.flat_map { |m| feeders(m) }
    { sf: [ sf ], qf: qf, r16: r16, r32: r32 }
  end

  def feeders(match)
    return [] unless match

    [ match.home_source_number, match.away_source_number ].compact.filter_map { |n| @matches[n] }
  end
end
