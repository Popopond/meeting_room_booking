class BookingsController < ApplicationController
  require 'rqrcode'
  before_action :set_booking, only: %i[ show edit update destroy ]
  before_action :authenticate_user!
  # GET /bookings or /bookings.json
  def index
  # @bookings = Booking.all
  bookings = Booking.includes(:room, :user).where("start_time >= ?", Time.now)
  render json: bookings, include: [:room, :user]
  end

  # GET /bookings/1 or /bookings/1.json
  def show
    booking = Booking.find(params[:id])
    render json: booking, include: [:room, :user]
  end

  # GET /bookings/new
  def new
    @booking = Booking.new
  end

  # GET /bookings/1/edit
  def edit
  end

  # POST /bookings or /bookings.json
  def create
    @booking = current_user.bookings.new(booking_params)
  
    if @booking.save
      render json: { message: "จองห้องประชุมสำเร็จ!", booking: @booking }, status: :created
    else
      render json: { errors: @booking.errors.full_messages }, status: :unprocessable_entity
    end
  end
  

  # PATCH/PUT /bookings/1 or /bookings/1.json
  def update
    respond_to do |format|
      if @booking.update(booking_params)
        format.html { redirect_to @booking, notice: "Booking was successfully updated." }
        format.json { render :show, status: :ok, location: @booking }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @booking.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bookings/1 or /bookings/1.json
  def destroy
    @booking = current_user.bookings.find(params[:id])
  
    if @booking.destroy
      render json: { message: "ยกเลิกการจองสำเร็จ!" }, status: :ok
    else
      render json: { errors: "ไม่สามารถยกเลิกการจองได้" }, status: :unprocessable_entity
    end
  end
  

  def generate_qr
    booking = Booking.find(params[:id])
    qr = RQRCode::QRCode.new("https://yourwebsite.com/checkin?booking_id=#{booking.id}")
    png = qr.as_png(size: 200).to_s
  
    send_data png, type: 'image/png', disposition: 'inline'
  end
  

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_booking
      @booking = Booking.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def booking_params
      params.require(:booking).permit(:room_id, :start_time, :end_time)
    end
end
