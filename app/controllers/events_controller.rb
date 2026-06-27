class EventsController < ApplicationController
  skip_after_action :verify_authorized, only: [ :index, :show ]
  skip_after_action :verify_policy_scoped

  def index
    @upcoming_events = Event.published.upcoming
    @past_events = Event.published.past.limit(6)
  end

  def show
    @event = Event.published.find(params[:id])
    @registration = current_user&.event_registrations&.find_by(event: @event, status: "confirmed") if user_signed_in?
  end
end
