class HomeController < ApplicationController
  before_action :authenticate_user!
  before_action :set_selected_date, only: [ :index ]
  before_action :load_bookings, only: [ :index ]

  def index
    @upcoming_bookings = current_user.bookings.upcoming.limit(5)
    @recent_bookings = current_user.bookings.past.limit(5)


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
    # start_date
    @start_date = if params[:start_date].present?
      Date.parse(params[:start_date])
    else
      Date.today
    end

    #  selected_date
    @selected_date = if params[:date].present?
      Date.parse(params[:date])
    else
      Date.today # change @start_date to Date.today
    end
  end

  def load_bookings
    # use beginning_of_day and end_of_day -> selected_date
    start_of_day = @selected_date.beginning_of_day
    end_of_day = @selected_date.end_of_day

    # โหลดการจองทั้งหมดสำหรับวันที่เลือก
    bookings = Booking.includes(:room, :user)
                     .where("start_time >= ? AND end_time <= ?", start_of_day, end_of_day)
                     .or(Booking.where("start_time < ? AND end_time > ?", end_of_day, start_of_day))

    # จัดกลุ่มการจองตาม room_id
    @bookings = bookings.group_by(&:room_id)
  end
end
