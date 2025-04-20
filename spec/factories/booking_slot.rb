FactoryBot.define do
  factory :booking_slot do
    booking
    start_time { Time.current }
    end_time { Time.current + 1.hour }
    complete { false }
  end
end
