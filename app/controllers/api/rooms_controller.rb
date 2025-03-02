class Api::RoomsController < ApplicationController
  before_action :authenticate_user!

  def index
    rooms = Room.includes(:status).all
    render json: rooms, include: [:status]
  end

  def show
    room = Room.find(params[:id])
    render json: room, include: [:status, :bookings]
  end
end

