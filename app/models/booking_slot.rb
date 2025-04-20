class BookingSlot < ApplicationRecord
  belongs_to :booking

  validates :start_time, :end_time, presence: true
  validate :end_time_after_start_time
  validate :no_overlapping_slots

  private

  def end_time_after_start_time
    return if end_time.blank? || start_time.blank?

    if end_time <= start_time
      errors.add(:end_time, "ต้องมากกว่าเวลาที่เริ่มจอง")
    end
  end

  def no_overlapping_slots
    return if booking.nil? || start_time.blank? || end_time.blank?

    overlapping = booking.booking_slots.where.not(id: id).any? do |slot|
      (start_time < slot.end_time) && (end_time > slot.start_time)
    end

    if overlapping
      errors.add(:base, "ช่วงเวลานี้ซ้ำซ้อนกับช่วงเวลาอื่นในการจองเดียวกัน")
    end
  end
end
