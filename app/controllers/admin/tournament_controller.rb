module Admin
  class TournamentController < BaseController
    skip_after_action :verify_authorized
    skip_after_action :verify_policy_scoped

    def edit
      @tournament = Tournament.current
    end

    def update
      @tournament = Tournament.current
      if @tournament.update(tournament_params)
        redirect_to edit_admin_tournament_path, notice: "Torneo actualizado."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def tournament_params
      params.require(:tournament).permit(:name, :entry_fee, :currency, :prize_description, :exact_score_bonus)
    end
  end
end
