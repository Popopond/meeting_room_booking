class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :room
  has_one :check_in, dependent: :destroy

  validates :start_time, :end_time, presence: true
  validate :end_time_after_start_time
  validate :room_availability

  before_create :generate_confirmation_code
  after_create :send_confirmation_email

  def status
    if complete
      "ยืนยันการจองแล้ว"
    elsif check_in_expired?
      "ยกเลิกการจอง"
    else
      "รอยืนยันการจอง"
    end
  end

  def check_in_expired?
    return false if complete
    Time.zone.now > (start_time + 15.minutes)
  end

  def can_check_in?
    return false if complete
    return false if check_in.present?
    current_time = Time.zone.now
    current_time.between?(start_time, start_time + 15.minutes)
  end

  def perform_check_in(current_user)
    return false unless can_check_in?

    transaction do
      create_check_in!(user: current_user, check_in: Time.zone.now)
      update!(complete: true)
    end
    true
  rescue ActiveRecord::RecordInvalid
    false
  end

  private

  def generate_confirmation_code
    loop do
      self.confirmation_code = SecureRandom.alphanumeric(6)
      break unless Booking.exists?(confirmation_code: confirmation_code)
    end
  end

  def end_time_after_start_time
    return if end_time.blank? || start_time.blank?
    if end_time <= start_time
      errors.add(:end_time, "ต้องมากกว่าเวลาที่เริ่มจอง")
    end
  end

  def room_availability
    return if room.blank? || start_time.blank? || end_time.blank?

    overlapping_bookings = room.bookings.where.not(id: id).where(
      "(start_time <= ? AND end_time > ?) OR (start_time < ? AND end_time >= ?)",
      end_time, start_time, end_time, start_time
    )

    if overlapping_bookings.exists?
      errors.add(:room, "ห้องนี้ถูกจองในช่วงเวลานี้แล้ว")
    end
  end

  def send_confirmation_email
    BookingMailer.with(booking: self).confirmation_email.deliver_later
  end
end
