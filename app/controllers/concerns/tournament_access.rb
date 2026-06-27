# Helpers compartidos por los controllers de la quiniela: expone el torneo
# actual y el gate de inscripción pagada (Entry paid) para jugar.
module TournamentAccess
  extend ActiveSupport::Concern

  included do
    helper_method :current_tournament, :current_entry
  end

  private

  def current_tournament
    @current_tournament ||= Tournament.current
  end

  def current_entry
    return nil unless user_signed_in?

    @current_entry ||= current_user.entry_for(current_tournament)
  end

  def require_paid_entry!
    return if current_entry&.paid?

    flash[:alert] = "Necesitas inscribirte al torneo para jugar."
    redirect_to new_entry_path
  end
end
