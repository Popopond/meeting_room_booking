class HomeController < ApplicationController
  before_action :authenticate_user!
  before_action :set_selected_date, only: [ :index ]

  def index
    @upcoming_bookings = current_user.bookings.upcoming.limit(5)
    @recent_bookings = current_user.bookings.past.limit(5)

    # Preload bookings for the selected date
    start_of_day = @selected_date.beginning_of_day
    end_of_day = @selected_date.end_of_day
    @bookings = Booking.includes(:room, :user)
                      .where(start_time: start_of_day..end_of_day)
                      .group_by(&:room_id)

    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("schedule_calendar", partial: "shared/room_schedule")
        ]
      end
    end
  end

  private

  def set_selected_date
    if params[:start_date].present?
      @start_date = Date.parse(params[:start_date])
    else
      @start_date = Date.today.beginning_of_week
    end

    if params[:date].present?
      @selected_date = Date.parse(params[:date])
    else
      @selected_date = @start_date
    end
  end
end
