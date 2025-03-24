class BookingsController < ApplicationController
  before_action :set_booking, only: %i[show edit update destroy check_in cancel]

  def index
    @bookings = Booking.includes(:room, :user).where("start_time >= ?", Time.now)
  
    if @bookings.empty?
      flash[:notice] = "ยังไม่มีการจองห้องประชุม"
    end
  end
  

  def show
    @booking = Booking.find(params[:id])
  end

  def new
    @booking = Booking.new
  end

  def edit
  end

  def create
    @booking = current_user.bookings.new(booking_params)
    @booking.complete = false
  
    if @booking.save
      # ✅ แก้ให้ดึงค่า Status ด้วย `status_name`
      unavailable_status = Status.find_by(status_name: "Unavailable") 
      @booking.room.update(status_id: unavailable_status&.id)
  
      # ✅ ตรวจสอบว่า Job ทำงานถูกต้องหรือไม่
      if @booking.room.status_id == unavailable_status&.id
        ReleaseRoomJob.set(wait_until: @booking.end_time).perform_later(@booking.id)
        redirect_to bookings_path, notice: "Booking created successfully."
      else
        flash[:alert] = "เกิดข้อผิดพลาดในการอัปเดตสถานะห้อง"
        redirect_to bookings_path
      end
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  
  
  

  def update
    if @booking.update(booking_params)
      render json: { message: "Booking was successfully updated.", booking: @booking }, status: :ok
    else
      render json: { errors: @booking.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @booking = current_user.bookings.find(params[:id])

    if @booking.destroy
      render json: { message: "ยกเลิกการจองสำเร็จ!" }, status: :ok
    else
      render json: { errors: "ไม่สามารถยกเลิกการจองได้" }, status: :unprocessable_entity
    end
  end

  def check_in
    if @booking.check_in_expired?
      # หากเช็คอินหมดเวลาให้ห้องกลับเป็น available
      @booking.room.update(available: true)
      @booking.destroy
      render json: { message: "การเช็คอินเกินเวลา ห้องถูกยกเลิก" }, status: :ok
    else
      @booking.check_in
      render json: { message: "เช็คอินสำเร็จ!" }, status: :ok
    end
  end

  def cancel
    @booking = current_user.bookings.find(params[:id])
    
    if @booking.destroy
      # อัพเดทสถานะห้องให้ว่าง
      available_status = Status.find_by(status_name: "Available")
      @booking.room.update(status_id: available_status&.id)
      
      redirect_to bookings_path, notice: "ยกเลิกการจองสำเร็จ"
    else
      redirect_to bookings_path, alert: "ไม่สามารถยกเลิกการจองได้"
    end
  end

  private

  def set_booking
    unless params[:id] =~ /^\d+$/
      render json: { error: "Invalid booking ID" }, status: :bad_request
      return
    end
  
    @booking = Booking.find(params[:id])
  end
  

  def booking_params
    params.require(:booking).permit(:room_id, :start_time, :end_time)
  end
end
