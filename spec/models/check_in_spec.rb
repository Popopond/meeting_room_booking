require 'rails_helper'

RSpec.describe CheckIn, type: :model do
  let(:user) { create(:user) }
  let(:room) { create(:room) }
  let(:booking) { create(:booking, user: user, room: room) }
  let(:check_in) { build(:check_in, user: user, booking: booking) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(check_in).to be_valid
    end

    it 'requires user' do
      check_in.user = nil
      expect(check_in).not_to be_valid
    end

    it 'requires booking' do
      check_in.booking = nil
      expect(check_in).not_to be_valid
    end

    it 'validates check_in_time_valid' do
      check_in.booking.start_time = Time.current + 1.hour
      expect(check_in).not_to be_valid
      expect(check_in.errors[:base]).to include("ยังไม่ถึงเวลาที่สามารถเช็คอินได้ (เช็คอินได้ตั้งแต่ #{check_in.booking.start_time.strftime("%H:%M")})")
    end
  end

  describe 'associations' do
    it 'belongs to user' do
      expect(CheckIn.reflect_on_association(:user).macro).to eq :belongs_to
    end

    it 'belongs to booking' do
      expect(CheckIn.reflect_on_association(:booking).macro).to eq :belongs_to
    end
  end

  describe 'callbacks' do
    it 'sets check_in_time before create' do
      check_in.save
      expect(check_in.check_in).not_to be_nil
    end

    it 'sets confirmation_code before create' do
      check_in.save
      expect(check_in.confirmation_code).to eq(booking.confirmation_code)
    end
  end
end
