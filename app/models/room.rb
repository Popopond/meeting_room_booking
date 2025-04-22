class Room < ApplicationRecord
    belongs_to :status
    has_many :bookings, dependent: :destroy
    has_one :room_qr_code, dependent: :destroy

    validates :name, presence: true, uniqueness: true
    validates :capacity, numericality: { only_integer: true, greater_than: 0 }

    after_create :create_qr_code

    def current_status
      current_booking = bookings.where("start_time <= ? AND end_time > ?", Time.current, Time.current).first
      if current_booking
        unavailable_status = Status.find_by(status_name: "Unavailable")
        return unavailable_status
      end
      available_status = Status.find_by(status_name: "Available")
      available_status
    end

    def current_booking
      bookings.joins(:booking_slots)
              .where("booking_slots.start_time <= ? AND booking_slots.end_time > ?", Time.current, Time.current)
              .first
    end

    def next_booking
      bookings.joins(:booking_slots)
              .where("booking_slots.start_time > ?", Time.current)
              .where("booking_slots.start_time + INTERVAL '15 minutes' > ? OR bookings.complete = ?", Time.current, true)
              .order("booking_slots.start_time ASC")
              .first
    end

    private

    def create_qr_code
      create_room_qr_code!
    end
end
