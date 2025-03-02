class Room < ApplicationRecord
    belongs_to :status
    has_many :bookings
  
    validates :name, presence: true, uniqueness: true
    validates :capacity, numericality: { only_integer: true, greater_than: 0 }
  end
  