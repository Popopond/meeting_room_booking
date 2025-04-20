FactoryBot.define do
  factory :booking do
    user
    room
    start_time { Time.current }
    end_time { Time.current + 1.hour }
    confirmation_code { SecureRandom.alphanumeric(6) }
    complete { false }

    transient do
      slot_start_time { Time.current }
      slot_end_time { Time.current + 1.hour }
    end

    after(:build) do |booking, evaluator|
      booking.booking_slots.build(
        start_time: evaluator.slot_start_time,
        end_time: evaluator.slot_end_time
      )
    end
  end
end
