class MatchesController < ApplicationController
  include TournamentAccess

  before_action :authenticate_user!
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  # Detalle social de un partido: las predicciones de todos los inscritos.
  def show
    @match = Match.find(params[:id])
    paid_user_ids = current_tournament.paid_entries.pluck(:user_id)
    @predictions = Prediction.where(match: @match, user_id: paid_user_ids).includes(:user).to_a
                             .sort_by { |p| p.user.display_name_or_default.downcase }
    @tally = @predictions.group_by(&:advancing_pick).transform_values(&:size)
  end
end
