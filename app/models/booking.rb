class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :room
  has_one :check_in, dependent: :destroy
  has_many :meeting_participants, dependent: :destroy
  has_many :participants, through: :meeting_participants, source: :user
  has_many :booking_slots, dependent: :destroy

  validates :room_id, presence: true
  validate :validate_booking_slots
  validate :room_availability

  before_create :generate_confirmation_code
  after_create :send_confirmation_email
  after_create :schedule_auto_reset

  accepts_nested_attributes_for :booking_slots, allow_destroy: true, reject_if: :all_blank

  scope :upcoming, -> { joins(:booking_slots).where("booking_slots.start_time > ?", Time.current).distinct.order("booking_slots.start_time ASC") }
  scope :past, -> { joins(:booking_slots).where("booking_slots.end_time < ?", Time.current).distinct.order("booking_slots.start_time DESC") }
  scope :current, -> {
    joins(:booking_slots)
      .where("booking_slots.start_time <= ? AND booking_slots.end_time > ?", Time.current, Time.current)
      .distinct
  }

  def start_time
    booking_slots.minimum(:start_time)
  end

  def end_time
    booking_slots.maximum(:end_time)
  end

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
      "รอเช็คอิน"
    end
  end

  def check_in_expired?
    return false if complete
    Time.zone.now > (start_time + 15.minutes)
  end

  def can_check_in?
    return false if complete

    current_time = Time.zone.now

    # หา slot ที่สามารถเช็คอินได้
    available_slot = booking_slots.order(start_time: :asc).find do |slot|
      next if slot.complete?

      slot_start = slot.start_time.in_time_zone
      slot_check_in_deadline = slot_start + 15.minutes

      # สามารถเช็คอินได้ถ้าอยู่ในช่วงเวลาที่กำหนด
      current_time.between?(slot_start, slot_check_in_deadline)
    end

    available_slot.present?
  end

  def current_or_next_slot
    current_time = Time.zone.now

    # หา slot ที่สามารถเช็คอินได้ตอนนี้
    booking_slots.order(start_time: :asc).find do |slot|
      next if slot.complete?

      slot_start = slot.start_time.in_time_zone
      slot_check_in_deadline = slot_start + 15.minutes

      current_time.between?(slot_start, slot_check_in_deadline)
    end
  end

  def perform_check_in(current_user)
    return false unless can_check_in?

    slot = current_or_next_slot
    return false unless slot

    transaction do
      check_in = build_check_in(
        user: current_user,
        booking_slot: slot
      )

      if check_in.save
        # Mark only this slot as complete
        slot.update!(complete: true)
        # Check if all slots are complete
        update!(complete: booking_slots.all?(&:complete))
        true
      else
        errors.add(:base, check_in.errors.full_messages.join(", "))
        raise ActiveRecord::Rollback
        false
      end
    end
  end

  def auto_reset_room
    current_time = Time.zone.now
    expired_slots = []
    all_slots_expired = true

    # ใช้ loaded booking_slots จาก eager loading
    booking_slots.each do |slot|
      next if slot.complete?

      slot_start = slot.start_time.in_time_zone
      check_in_deadline = slot_start + 15.minutes

      if current_time > check_in_deadline
        expired_slots << slot
      else
        all_slots_expired = false
      end
    end

    return if expired_slots.empty?

    # ทำ transaction เพื่อให้การอัพเดทข้อมูลเป็น atomic
    Booking.transaction do
      if all_slots_expired
        # ถ้าทุก slots หมดเวลา ลบการจองทั้งหมด
        available_status = Status.find_by(status_name: "Available")
        room.update!(status_id: available_status&.id)
        self.destroy!
      else
        # ลบเฉพาะ slots ที่หมดเวลา
        expired_slots.each(&:destroy!)
        # อัพเดทสถานะห้องถ้าไม่มีการจองที่ active
        unless booking_slots.any? { |slot| !slot.complete? && current_time <= (slot.start_time.in_time_zone + 15.minutes) }
          available_status = Status.find_by(status_name: "Available")
          room.update!(status_id: available_status&.id)
        end
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

  def validate_booking_slots
    if booking_slots.empty?
      errors.add(:base, "ต้องระบุช่วงเวลาอย่างน้อย 1 ช่วง")
    end

    # ตรวจสอบว่าช่วงเวลาไม่ซ้ำซ้อนกันเอง
    slots = booking_slots.sort_by(&:start_time)
    slots.each_cons(2) do |slot1, slot2|
      if slot1.end_time > slot2.start_time
        errors.add(:base, "ช่วงเวลาที่เลือกซ้ำซ้อนกัน")
        break
      end
    end
  end

  def room_availability
    return if room.blank? || booking_slots.empty?

    # จัดเรียงช่วงเวลาตาม start_time
    sorted_slots = booking_slots.sort_by(&:start_time)

    # ตรวจสอบการจองที่ซ้ำซ้อนสำหรับแต่ละช่วงเวลา
    sorted_slots.each do |slot|
      overlapping_slots = BookingSlot
        .joins(:booking)
        .where(booking: { room_id: room_id })
        .where.not(booking_id: id)
        .where(
          "(booking_slots.start_time, booking_slots.end_time) OVERLAPS (?, ?)",
          slot.start_time, slot.end_time
        )

      if overlapping_slots.exists?
        errors.add(:base, "ห้องนี้ถูกจองในช่วงเวลา #{slot.start_time.strftime("%H:%M")} - #{slot.end_time.strftime("%H:%M")} แล้ว")
        break
      end
    end
  end

  def send_confirmation_email
    BookingMailer.with(booking: self).confirmation_email.deliver_later
  end

  def schedule_auto_reset
    booking_slots.each do |slot|
      AutoResetRoomJob.set(wait_until: slot.start_time + 15.minutes).perform_later(id)
    end
  end
end
