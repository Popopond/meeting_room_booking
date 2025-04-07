FactoryBot.define do
  factory :check_in do
    user
    booking
    check_in { Time.current }
    confirmation_code { SecureRandom.alphanumeric(6) }
  end
end
