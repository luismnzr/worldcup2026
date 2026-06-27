class EntriesController < ApplicationController
  include TournamentAccess

  before_action :authenticate_user!
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def new
    if current_entry&.paid?
      redirect_to predictions_path, notice: "Ya estás inscrito. ¡A predecir!"
    end
  end

  def create
    if current_entry&.paid?
      redirect_to predictions_path, notice: "Ya estás inscrito." and return
    end

    entry = current_user.entries.find_or_create_by!(tournament: current_tournament) do |e|
      e.amount = current_tournament.entry_fee
    end

    session = StripeCheckoutService.create_entry_session(
      user: current_user,
      tournament: current_tournament,
      entry: entry,
      success_url: entry_success_url,
      cancel_url: new_entry_url
    )

    entry.update!(stripe_checkout_session_id: session.id, amount: current_tournament.entry_fee)
    redirect_to session.url, allow_other_host: true, status: :see_other
  rescue Stripe::StripeError => e
    flash[:alert] = "Error de pago: #{e.message}"
    redirect_to new_entry_path
  end

  def success
    flash[:notice] = "¡Pago recibido! Tu inscripción se confirma en unos segundos."
    redirect_to predictions_path
  end
end
