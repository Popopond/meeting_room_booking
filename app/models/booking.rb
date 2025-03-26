class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :room
  has_one :check_in, dependent: :destroy
  has_many :meeting_participants, dependent: :destroy
  has_many :participants, through: :meeting_participants, source: :user

  validates :start_time, :end_time, presence: true
  validate :end_time_after_start_time
  validate :room_availability

  before_create :generate_confirmation_code
  after_create :send_confirmation_email

  scope :upcoming, -> { where('start_time > ?', Time.current).order(start_time: :asc) }
  scope :past, -> { where('end_time < ?', Time.current).order(start_time: :desc) }
  scope :current, -> { where('start_time <= ? AND end_time > ?', Time.current, Time.current) }

  def add_participant(user)
    return false if user == self.user
    meeting_participants.create(user: user)
  end

  def remove_participant(user)
    meeting_participants.find_by(user: user)&.destroy
  end

  def participant?(user)
    participants.include?(user)
  end

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
    return false if complete || check_in.present?
    
    current_time = Time.zone.now
    booking_start = start_time.in_time_zone
    check_in_deadline = booking_start + 15.minutes
    
    current_time.between?(booking_start, check_in_deadline)
  end

  def perform_check_in(current_user)
    return false unless can_check_in?

    transaction do
      check_in = build_check_in(user: current_user)
      if check_in.save
        update!(complete: true)
        true
      else
        errors.add(:base, check_in.errors.full_messages.join(", "))
        raise ActiveRecord::Rollback
        false
      end
    end
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
    errors.add(:end_time, "ต้องมากกว่าเวลาที่เริ่มจอง") if end_time <= start_time
  end

  def room_availability
    return if room.blank? || start_time.blank? || end_time.blank?

    overlapping_bookings = room.bookings.where.not(id: id).where(
      "(start_time < ? AND end_time > ?)",
      end_time, start_time
    )

    errors.add(:room, "ห้องนี้ถูกจองในช่วงเวลานี้แล้ว") if overlapping_bookings.exists?
  end

  def send_confirmation_email
    BookingMailer.with(booking: self).confirmation_email.deliver_later
  end
end
