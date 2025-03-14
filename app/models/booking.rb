class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :room
  has_one :check_in, dependent: :destroy

  before_create :generate_confirmation_code
  after_create :schedule_check_in_reminder

  validates :start_time, :end_time, presence: true
  validate :end_time_after_start_time
  validate :room_availability

  def generate_confirmation_code
    self.confirmation_code = SecureRandom.alphanumeric(6)
  end

  def room_availability
    if Booking.where(room_id: room_id)
              .where("start_time < ? AND end_time > ?", end_time, start_time)
              .exists?
      errors.add(:base, "This room is already booked for the selected time.")
    end
  end

  def end_time_after_start_time
    if end_time <= start_time
      errors.add(:end_time, "ต้องมากกว่าเวลาเริ่มต้น")
    end
  end

  def check_in
    check_in = self.build_check_in(user: self.user, check_in: Time.now)
    check_in.save
  end

  def check_in_expired?
    check_in_time = self.check_in&.check_in
    check_in_time.nil? || (Time.now - check_in_time) > 15.minutes
  end

  private

  def schedule_check_in_reminder
    # ตั้งเวลาเตือนเช็คอินที่นี่
  end
end
