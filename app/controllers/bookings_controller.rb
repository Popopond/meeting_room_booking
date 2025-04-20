class BookingsController < ApplicationController
  before_action :set_booking, only: %i[show edit update destroy check_in cancel add_participant remove_participant]
  before_action :authenticate_user!

  def index
    @bookings = if current_user.role == "admin"
      Booking.includes(:room, :user, :booking_slots)
            .joins(:booking_slots)
            .order("booking_slots.start_time DESC")
            .distinct
    else
      current_user.bookings
                 .includes(:room, :booking_slots)
                 .joins(:booking_slots)
                 .order("booking_slots.start_time DESC")
                 .distinct
    end
    flash.now[:notice] = "ยังไม่มีการจองห้องประชุม" if @bookings.empty?
  end

  def show
    @booking = Booking.includes(:booking_slots).find(params[:id])
    @available_users = User.exclude_user(@booking.user)
                          .where.not(id: @booking.participants.pluck(:id))
                          .select(:id, :username, :avatar)
  end

  def new
    @booking = current_user.bookings.build

    if params[:room_id].present? && params[:date].present? && params[:slots].present?
      @booking.room_id = params[:room_id]

      params[:slots].each do |_, slot_params|
        start_time = Time.zone.parse("#{params[:date]} #{slot_params[:start_time]}")
        end_time = Time.zone.parse("#{params[:date]} #{slot_params[:end_time]}")
        @booking.booking_slots.build(start_time: start_time, end_time: end_time)
      end
    else
      @booking.booking_slots.build # Build at least one slot
    end

    @rooms = Room.all
  end

  def edit
  end

  def create
    @booking = current_user.bookings.build(booking_params.except(:booking_slots_attributes))

    if params[:booking][:booking_slots_attributes].present?
      # Sort slots by start time and group continuous slots
      slots = params[:booking][:booking_slots_attributes].values.map do |slot_params|
        date = Date.parse(slot_params[:date])
        {
          start_time: Time.zone.parse("#{date} #{slot_params[:start_time]}"),
          end_time: Time.zone.parse("#{date} #{slot_params[:end_time]}")
        }
      end.sort_by { |slot| slot[:start_time] }

      # Group continuous slots
      current_group = []
      slots.each do |slot|
        if current_group.empty? || current_group.last[:end_time] == slot[:start_time]
          current_group << slot
        else
          # Create booking slot for the previous group
          @booking.booking_slots.build(
            start_time: current_group.first[:start_time],
            end_time: current_group.last[:end_time]
          )
          # Start new group
          current_group = [ slot ]
        end
      end

      # Don't forget to create booking slot for the last group
      if current_group.any?
        @booking.booking_slots.build(
          start_time: current_group.first[:start_time],
          end_time: current_group.last[:end_time]
        )
      end
    end

    respond_to do |format|
      if @booking.save
        update_room_status
        format.html {
          flash[:success] = success_message
          redirect_to booking_url(@booking)
        }
        format.json { render :show, status: :created, location: @booking }
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
        format.html { redirect_to booking_url(@booking), notice: "อัพเดทการจองเรียบร้อยแล้ว" }
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
      handle_check_in_expired
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
      update_room_status_to_available
      redirect_to bookings_url, notice: "ยกเลิกการจองเรียบร้อยแล้ว"
    else
      redirect_to bookings_url, alert: "ไม่สามารถยกเลิกการจองได้"
    end
  end

  def add_participant
    user = User.find(params[:user_id])

    if @booking.add_participant(user)
      redirect_to @booking, notice: "เพิ่มผู้เข้าร่วมประชุมเรียบร้อยแล้ว"
    else
      redirect_to @booking, alert: "ไม่สามารถเพิ่มผู้เข้าร่วมประชุมได้"
    end
  end

  def remove_participant
    user = User.find(params[:user_id])

    if @booking.remove_participant(user)
      redirect_to @booking, notice: "ลบผู้เข้าร่วมประชุมเรียบร้อยแล้ว"
    else
      redirect_to @booking, alert: "ไม่สามารถลบผู้เข้าร่วมประชุมได้"
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
    params.require(:booking).permit(
      :room_id,
      :title,
      :description,
      booking_slots_attributes: [ :id, :start_time, :end_time, :_destroy ]
    )
  end

  def update_room_status
    if Time.current >= @booking.start_time
      unavailable_status = Status.find_by(status_name: "Unavailable")
      @booking.room.update(status_id: unavailable_status&.id)

      if @booking.room.status_id == unavailable_status&.id
        ReleaseRoomJob.set(wait_until: @booking.end_time).perform_later(@booking.id)
      else
        flash[:alert] = "เกิดข้อผิดพลาดในการอัปเดตสถานะห้อง"
      end
    end
  end

  def update_room_status_to_available
    available_status = Status.find_by(status_name: "Available")
    @booking.room.update(status_id: available_status&.id)
  end

  def handle_check_in_expired
    @booking.room.update(available: true)
    @booking.destroy
    render json: { message: "การเช็คอินเกินเวลา ห้องถูกยกเลิก" }, status: :ok
  end

  def success_message
    "การจองสำเร็จ! รหัสยืนยันของคุณคือ: #{@booking.confirmation_code}"
  end
end
