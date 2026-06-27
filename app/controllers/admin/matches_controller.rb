module Admin
  class MatchesController < BaseController
    skip_after_action :verify_authorized
    skip_after_action :verify_policy_scoped

    def index
      @matches_by_stage = Match.ordered.group_by(&:stage)
    end

    def edit
      @match = Match.find(params[:id])
    end

    # Edición manual de equipos / kickoff / sede / etiquetas.
    def update
      @match = Match.find(params[:id])
      if @match.update(match_params)
        redirect_to admin_matches_path, notice: "Partido actualizado."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    # Captura de resultado: dispara scoring + propagación + broadcast.
    def record_result
      match = Match.find(params[:id])
      MatchResultService.record!(
        match,
        home_score: params.dig(:match, :home_score),
        away_score: params.dig(:match, :away_score),
        advancing_team: params.dig(:match, :advancing_team)
      )
      redirect_to admin_matches_path, notice: "Resultado guardado: avanza #{match.advancing_team}."
    rescue MatchResultService::InvalidResult => e
      redirect_to edit_admin_match_path(match), alert: e.message
    end

    private

    def match_params
      params.require(:match).permit(:home_team, :away_team, :home_label, :away_label,
                                    :kickoff_at, :venue, :status)
    end
  end
end
