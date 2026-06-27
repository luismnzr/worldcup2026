class EventRegistrationsController < ApplicationController
  def create
    @event = Event.published.find(params[:event_id])
    @registration = @event.event_registrations.new(user: current_user, status: "confirmed")
    authorize @registration

    if @event.full?
      redirect_to event_path(@event), alert: "Este evento está lleno."
      return
    end

    ActiveRecord::Base.transaction do
      @registration.save!
      @event.decrement!(:spots_remaining) if @event.spots_remaining.present?
    end

    redirect_to event_path(@event), notice: "Te has registrado exitosamente."
  rescue ActiveRecord::RecordInvalid
    redirect_to event_path(@event), alert: "No se pudo completar el registro."
  end

  def destroy
    @registration = EventRegistration.find(params[:id])
    authorize @registration
    @event = @registration.event

    ActiveRecord::Base.transaction do
      @registration.cancel!
      @event.increment!(:spots_remaining) if @event.spots_remaining.present?
    end

    redirect_to event_path(@event), notice: "Tu registro ha sido cancelado."
  end
end
