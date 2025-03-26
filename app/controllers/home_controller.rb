class HomeController < ApplicationController
  before_action :authenticate_user!
  before_action :set_selected_date, only: [:index]

  def index
    @upcoming_bookings = current_user.bookings.upcoming.limit(5)
    @recent_bookings = current_user.bookings.past.limit(5)
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  private

  def set_selected_date
    if params[:start_date].present?
      @start_date = Date.parse(params[:start_date])
    else
      @start_date = Date.today.beginning_of_week
    end

    @selected_date = params[:date].present? ? Date.parse(params[:date]) : Date.today
  end
end
