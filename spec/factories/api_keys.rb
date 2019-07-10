FactoryBot.define do
  factory :api_key do
    key { Faker::Alphanumeric.alphanumeric(10) }
    active { true }
  end
end
