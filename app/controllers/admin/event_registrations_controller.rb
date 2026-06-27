module Admin
  class EventRegistrationsController < BaseController
    def create
      @event = Event.find(params[:event_id])
      authorize @event, :update?

      user = User.find(params[:user_id])

      if @event.event_registrations.where(user: user).where.not(status: "cancelled").exists?
        redirect_to admin_event_path(@event), alert: "#{user.full_name} ya está registrado/a en este evento."
        return
      end

      if @event.full?
        redirect_to admin_event_path(@event), alert: "Este evento está lleno."
        return
      end

      ActiveRecord::Base.transaction do
        @event.event_registrations.create!(user: user, status: "confirmed")
        @event.decrement!(:spots_remaining) if @event.spots_remaining.present?
      end

      redirect_to admin_event_path(@event), notice: "#{user.full_name} registrado/a exitosamente."
    rescue ActiveRecord::RecordInvalid => e
      redirect_to admin_event_path(@event), alert: "No se pudo registrar: #{e.message}"
    end

    def destroy
      @event = Event.find(params[:event_id])
      authorize @event, :update?

      registration = @event.event_registrations.find(params[:id])

      ActiveRecord::Base.transaction do
        registration.cancel!
        @event.increment!(:spots_remaining) if @event.spots_remaining.present?
      end

      redirect_to admin_event_path(@event), notice: "Registro cancelado exitosamente."
    end
  end
end
