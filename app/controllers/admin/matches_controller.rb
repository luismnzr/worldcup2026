module Admin
  class MatchesController < BaseController
    skip_after_action :verify_authorized
    skip_after_action :verify_policy_scoped

    def index
      @matches_by_stage = Match.ordered.group_by(&:stage)
      @sync_enabled = FootballDataClient.new.configured?
    end

    # Sincroniza resultados ahora mismo desde football-data.org (override del cron).
    def sync
      client = FootballDataClient.new
      unless client.configured?
        redirect_to admin_matches_path, alert: "Falta configurar FOOTBALL_DATA_API_TOKEN para sincronizar." and return
      end

      summary = ResultsSyncService.call(client.world_cup_matches)
      notice = "Sincronización lista: #{summary.applied.size} resultado(s) aplicado(s)."
      notice += " #{summary.unresolved.size} sin mapear." if summary.unresolved.any?
      redirect_to admin_matches_path, notice: notice
    rescue FootballDataClient::Error => e
      redirect_to admin_matches_path, alert: "No se pudo sincronizar: #{e.message}"
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
