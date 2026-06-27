module Admin
  class EventsController < BaseController
    def index
      @events = policy_scope(Event).order(date: :desc)
      @pagy, @events = pagy(@events)
    end

    def show
      @event = Event.find(params[:id])
      authorize @event
      @registrations = @event.event_registrations.includes(:user).where(status: "confirmed").order(created_at: :desc)
      registered_user_ids = @registrations.pluck(:user_id)
      @available_users = User.where.not(id: registered_user_ids).order(:first_name, :last_name)
    end

    def new
      @event = Event.new
      authorize @event
    end

    def create
      @event = Event.new(event_params)
      authorize @event
      @event.spots_remaining = @event.capacity if @event.capacity.present?

      if @event.save
        redirect_to admin_events_path, notice: "Evento creado exitosamente."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @event = Event.find(params[:id])
      authorize @event
    end

    def update
      @event = Event.find(params[:id])
      authorize @event

      old_capacity = @event.capacity
      if @event.update(event_params)
        if event_params[:capacity].present? && old_capacity != @event.capacity
          diff = @event.capacity.to_i - old_capacity.to_i
          @event.update_column(:spots_remaining, [ @event.spots_remaining.to_i + diff, 0 ].max)
        end
        redirect_to admin_events_path, notice: "Evento actualizado exitosamente."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @event = Event.find(params[:id])
      authorize @event
      @event.destroy
      redirect_to admin_events_path, notice: "Evento eliminado."
    end

    private

    def event_params
      params.require(:event).permit(:title, :description, :date, :end_date, :start_time, :end_time, :location, :capacity, :price, :published, :in_person_payment_only, :cover_image)
    end
  end
end
