class PredictionsController < ApplicationController
  include TournamentAccess

  before_action :authenticate_user!
  before_action :require_paid_entry!
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def index
    @open_matches = Match.select(&:predictable?).sort_by { |m| [ m.kickoff_at, m.number ] }
    @locked_matches = Match.where.not(home_team: nil).where.not(away_team: nil)
                           .where("kickoff_at <= ?", Time.current).ordered
    @predictions = current_user.predictions.index_by(&:match_id)
  end

  def upsert
    match = Match.find(params[:match_id])

    unless match.predictable?
      redirect_to predictions_path, alert: "Este partido ya no está abierto para predicciones." and return
    end

    prediction = current_user.predictions.find_or_initialize_by(match: match)
    prediction.assign_attributes(prediction_params)

    if prediction.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "match_#{match.id}",
            partial: "predictions/match",
            locals: { match: match, prediction: prediction }
          )
        end
        format.html { redirect_to predictions_path, notice: "¡Predicción guardada!" }
      end
    else
      redirect_to predictions_path, alert: prediction.errors.full_messages.to_sentence
    end
  end

  private

  def prediction_params
    params.require(:prediction).permit(:advancing_pick, :home_score, :away_score)
  end
end
