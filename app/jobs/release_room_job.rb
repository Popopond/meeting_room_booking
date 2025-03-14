class ReleaseRoomJob < ApplicationJob
  queue_as :default

  def perform(booking_id)
    booking = Booking.find_by(id: booking_id)
    return unless booking

    available_status = Status.find_by(status_name: "Available")
    booking.room.update(status_id: available_status&.id) if available_status
  end
end
