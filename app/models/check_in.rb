class CheckIn < ApplicationRecord
  belongs_to :user
  belongs_to :booking

  validates :check_in, presence: true

  def check_in_expired?
    # เช็คว่าเกินเวลาที่จองหรือยัง
    Time.now > booking.end_time
  end
end
