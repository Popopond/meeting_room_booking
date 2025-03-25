class CheckIn < ApplicationRecord
  belongs_to :user
  belongs_to :booking

  validates :check_in, presence: true
  validates :confirmation_code, presence: true
  validate :check_in_time_valid
  validate :no_duplicate_check_in
  validate :booking_not_complete

  before_create :set_check_in_time

  private

  def check_in_expired?
    self.check_in ||= Time.current 
  end

  def check_in_time_valid
    return if check_in.blank? || booking.blank?

    current_time = Time.zone.now
    start_time = booking.start_time
    check_in_deadline = start_time + 15.minutes

    if current_time < start_time
      errors.add(:check_in, "ยังไม่ถึงเวลาที่สามารถเช็คอินได้ (เช็คอินได้ตั้งแต่ #{start_time.strftime("%H:%M")})")
      return
    end

    if current_time > check_in_deadline
      errors.add(:check_in, "หมดเวลาเช็คอินแล้ว (เช็คอินได้ถึง #{check_in_deadline.strftime("%H:%M")} เท่านั้น)")
      return
    end
  end

  def no_duplicate_check_in
    return if booking.blank?
    
    if booking.check_in.present?
      errors.add(:base, "คุณได้เช็คอินเรียบร้อยแล้ว")
    end
  end

  def booking_not_complete
    return if booking.blank?
    
    if booking.complete?
      errors.add(:base, "การจองนี้ถูกยืนยันไปแล้ว")
    end
  end
end
