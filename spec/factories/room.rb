FactoryBot.define do
  factory :room do
    name { Faker::Company.name }
    capacity { rand(5..20) }
    description { Faker::Lorem.paragraph }
    association :status, factory: :status
  end
end 