class BookingsController < ApplicationController
  before_action :set_booking, only: %i[show edit update destroy check_in cancel]
  before_action :authenticate_user!

  def index
    @bookings = current_user.bookings.includes(:room).order(start_time: :desc)
  
    if @bookings.empty?
      flash[:notice] = "ยังไม่มีการจองห้องประชุม"
    end
  end
  

  def show
    @booking = Booking.find(params[:id])
  end

  def new
    @booking = current_user.bookings.build
    @rooms = Room.all
  end

  def edit
  end

  def create
    @booking = current_user.bookings.build(booking_params)

    respond_to do |format|
      if @booking.save
        # ✅ แก้ให้ดึงค่า Status ด้วย `status_name`
        unavailable_status = Status.find_by(status_name: "Unavailable") 
        @booking.room.update(status_id: unavailable_status&.id)
  
        # ✅ ตรวจสอบว่า Job ทำงานถูกต้องหรือไม่
        if @booking.room.status_id == unavailable_status&.id
          ReleaseRoomJob.set(wait_until: @booking.end_time).perform_later(@booking.id)
          format.html { redirect_to booking_url(@booking), notice: "การจองสำเร็จ! รหัสยืนยันของคุณคือ: #{@booking.confirmation_code}" }
          format.json { render :show, status: :created, location: @booking }
        else
          flash[:alert] = "เกิดข้อผิดพลาดในการอัปเดตสถานะห้อง"
          @rooms = Room.all
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @booking.errors, status: :unprocessable_entity }
        end
      else
        @rooms = Room.all
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @booking.errors, status: :unprocessable_entity }
      end
    end
  end
  
  
  
  

  def update
    respond_to do |format|
      if @booking.update(booking_params)
        format.html { redirect_to booking_url(@booking), notice: "Booking was successfully updated." }
        format.json { render :show, status: :ok, location: @booking }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @booking.errors, status: :unprocessable_entity }
      end
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
    
    if @booking.complete?
      redirect_to bookings_url, alert: "ไม่สามารถยกเลิกการจองที่เช็คอินแล้วได้"
      return
    end
    
    if @booking.destroy
      # อัพเดทสถานะห้องให้ว่าง
      available_status = Status.find_by(status_name: "Available")
      @booking.room.update(status_id: available_status&.id)
      
      redirect_to bookings_url, notice: "ยกเลิกการจองเรียบร้อยแล้ว"
    else
      redirect_to bookings_url, alert: "ไม่สามารถยกเลิกการจองได้"
    end
  end

  private

  def set_booking
    unless params[:id] =~ /^\d+$/
      render json: { error: "Invalid booking ID" }, status: :bad_request
      return
    end
  
    @booking = current_user.bookings.find(params[:id])
  end
  

  def booking_params
    params.require(:booking).permit(:room_id, :start_time, :end_time)
  end
end
