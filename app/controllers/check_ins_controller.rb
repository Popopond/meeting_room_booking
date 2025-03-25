class CheckInsController < ApplicationController
  before_action :authenticate_user!

  def new
    @booking = Booking.find_by(confirmation_code: params[:code]) if params[:code]
  end

  def create
    @booking = Booking.find_by(confirmation_code: params[:confirmation_code])
    
    if @booking.nil?
      flash[:alert] = "ไม่พบรหัสยืนยันนี้ในระบบ"
      redirect_to new_check_in_path
      return
    end

    if @booking.check_in_expired?
      flash[:alert] = "หมดเวลาเช็คอินแล้ว (เช็คอินได้ภายใน 15 นาทีแรกของการจองเท่านั้น)"
      redirect_to new_check_in_path
      return
    end

    if @booking.complete?
      flash[:alert] = "การจองนี้ถูกยืนยันไปแล้ว"
      redirect_to new_check_in_path
      return
    end

    if @booking.check_in.present?
      flash[:alert] = "คุณได้เช็คอินเรียบร้อยแล้ว"
      redirect_to new_check_in_path
      return
    end

    unless @booking.can_check_in?
      flash[:alert] = "ไม่สามารถเช็คอินได้ในขณะนี้ (เช็คอินได้ตั้งแต่ #{@booking.start_time.strftime("%H:%M")} ถึง #{(@booking.start_time + 15.minutes).strftime("%H:%M")} เท่านั้น)"
      redirect_to new_check_in_path
      return
    end

    if @booking.perform_check_in(current_user)
      flash[:notice] = "เช็คอินสำเร็จ! คุณสามารถเข้าห้องประชุมได้แล้ว"
      redirect_to new_check_in_path(code: @booking.confirmation_code)
    else
      flash[:alert] = "เกิดข้อผิดพลาดในการเช็คอิน กรุณาลองใหม่อีกครั้ง"
      redirect_to new_check_in_path
    end
  rescue => e
    flash[:alert] = "เกิดข้อผิดพลาดในการเช็คอิน: #{e.message}"
    redirect_to new_check_in_path
  end

  private

  def within_check_in_period?(booking)
    check_in_deadline = booking.start_time + 15.minutes
    Time.current.between?(booking.start_time, check_in_deadline)
  end
end
