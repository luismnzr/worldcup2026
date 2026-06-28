class MatchesController < ApplicationController
  include TournamentAccess

  before_action :authenticate_user!
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  # Detalle social de un partido: las predicciones de los demás SOLO se revelan
  # cuando el partido cierra (kickoff), para que nadie copie antes.
  def show
    @match = Match.find(params[:id])
    @revealed = @match.locked?

    paid_user_ids = current_tournament.paid_entries.pluck(:user_id)
    scope = Prediction.where(match: @match, user_id: paid_user_ids)
    @prediction_count = scope.count

    if @revealed
      @predictions = scope.includes(:user).to_a
                          .sort_by { |p| p.user.display_name_or_default.downcase }
      @tally = @predictions.group_by(&:advancing_pick).transform_values(&:size)
    end
  end
end
