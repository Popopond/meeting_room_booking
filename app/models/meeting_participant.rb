class MeetingParticipant < ApplicationRecord
  belongs_to :booking
  belongs_to :user

  validates :booking_id, uniqueness: { scope: :user_id }
end 