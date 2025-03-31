FactoryBot.define do
  factory :booking do
    user
    room
    start_time { Time.current }
    end_time { Time.current + 1.hour }
    confirmation_code { SecureRandom.alphanumeric(6) }
    complete { false }
  end
end 