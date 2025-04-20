FactoryBot.define do
  factory :check_in do
    user
    booking
    check_in { Time.current }
    after(:build) do |check_in|
      check_in.booking_slot = check_in.booking.booking_slots.first
      check_in.confirmation_code = check_in.booking.confirmation_code
    end
  end
end
