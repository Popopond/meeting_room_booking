class Room < ApplicationRecord
    belongs_to :status
    has_many :bookings
  
    validates :name, presence: true, uniqueness: true
    validates :capacity, numericality: { only_integer: true, greater_than: 0 }

    def current_status
      current_booking = bookings.where("start_time <= ? AND end_time > ?", Time.current, Time.current).first
      if current_booking
        unavailable_status = Status.find_by(status_name: "Unavailable")
        return unavailable_status
      end
      available_status = Status.find_by(status_name: "Available")
      available_status
    end
end
  