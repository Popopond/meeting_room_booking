class AutoResetRoomJob < ApplicationJob
  queue_as :default

  def perform(booking_id)
    # Eager load booking_slots และ room พร้อมกับ status เพื่อลด queries
    booking = Booking.includes(:booking_slots, room: :status).find_by(id: booking_id)
    return unless booking

    booking.auto_reset_room

    # ใช้ loaded booking_slots จาก eager loading
    remaining_slots = booking.booking_slots.select { |slot| !slot.complete? }
    if remaining_slots.any?
      self.class.set(wait: 1.minute).perform_later(booking_id)
    end
  end
end
