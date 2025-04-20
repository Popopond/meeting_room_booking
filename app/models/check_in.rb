class CheckIn < ApplicationRecord
  belongs_to :user
  belongs_to :booking
  belongs_to :booking_slot

  validate :check_in_time_valid

  before_create :set_check_in_time
  before_create :set_confirmation_code

  private

  def set_check_in_time
    self.check_in = Time.zone.now
  end

  def set_confirmation_code
    self.confirmation_code = booking.confirmation_code
  end

  def check_in_time_valid
    return if booking_slot.blank?

    current_time = Time.zone.now
    start_time = booking_slot.start_time.in_time_zone
    check_in_deadline = start_time + 15.minutes

    if current_time < start_time
      errors.add(:base, "ยังไม่ถึงเวลาที่สามารถเช็คอินได้ (เช็คอินได้ตั้งแต่ #{start_time.strftime("%H:%M")})")
      return
    end

    if current_time > check_in_deadline
      errors.add(:base, "หมดเวลาเช็คอินแล้ว (เช็คอินได้ถึง #{check_in_deadline.strftime("%H:%M")} เท่านั้น)")
      nil
    end

    if booking_slot.complete?
      errors.add(:base, "ช่วงเวลานี้ถูกเช็คอินไปแล้ว")
      nil
    end
  end
end
