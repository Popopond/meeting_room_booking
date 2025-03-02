class CheckIn < ApplicationRecord
  belongs_to :user
  belongs_to :booking

  validate :valid_confirmation_code

  private

  def valid_confirmation_code
    unless booking.confirmation_code == confirmation_code
      errors.add(:confirmation_code, "รหัสยืนยันไม่ถูกต้อง")
    end
  end
end
