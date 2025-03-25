class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @upcoming_bookings = current_user.bookings.upcoming.limit(5)
    @recent_bookings = current_user.bookings.past.limit(5)
  end
end
