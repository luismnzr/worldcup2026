module Admin
  class EntriesController < BaseController
    skip_after_action :verify_authorized
    skip_after_action :verify_policy_scoped

    def index
      @tournament = Tournament.current
      @entries = @tournament.entries.includes(:user).order(created_at: :desc)
    end

    # Toggle manual de pago — fallback por si un pago se queda colgado.
    def toggle_paid
      entry = Entry.find(params[:id])
      if entry.paid?
        entry.update!(status: :pending, paid_at: nil)
      else
        entry.mark_paid!
      end
      LeaderboardService.broadcast(entry.tournament)
      redirect_to admin_entries_path, notice: "Inscripción de #{entry.user.display_name_or_default} marcada como #{entry.status}."
    end
  end
end
