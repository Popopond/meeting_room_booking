FactoryBot.define do
  factory :booking do
    user
    room
    title { "Meeting" }
    description { "Regular team meeting" }
    expected_participants { 4 }
    complete { false }
    confirmation_code { SecureRandom.alphanumeric(6) }

    # Create a default booking slot
    after(:build) do |booking|
      booking.booking_slots << build(:booking_slot, booking: booking)
    end

    trait :with_check_in do
      after(:create) do |booking|
        create(:check_in, booking: booking)
      end
    end

    trait :with_participants do
      transient do
        participants_count { 2 }
      end

      after(:create) do |booking, evaluator|
        create_list(:meeting_participant, evaluator.participants_count, booking: booking)
      end
    end

    trait :complete do
      complete { true }
      after(:create) do |booking|
        booking.booking_slots.each { |slot| slot.update(complete: true) }
      end
    end

    trait :with_multiple_slots do
      transient do
        slots_count { 2 }
      end

      after(:build) do |booking, evaluator|
        # Clear any existing slots
        booking.booking_slots.clear

        # Create sequential slots
        evaluator.slots_count.times do |i|
          booking.booking_slots << build(:booking_slot,
            booking: booking,
            start_time: Time.current + i.hours,
            end_time: Time.current + (i + 1).hours
          )
        end
      end
    end
  end
end
