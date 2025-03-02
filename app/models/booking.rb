class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :room

  before_create :generate_confirmation_code

  validates :start_time, :end_time, presence: true
  validate :end_time_after_start_time

  private

  def generate_confirmation_code
    self.confirmation_code = SecureRandom.alphanumeric(6)
  end

  def end_time_after_start_time
    if end_time <= start_time
      errors.add(:end_time, "ต้องมากกว่าเวลาเริ่มต้น")
    end
  end
end
