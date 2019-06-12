FactoryBot.define do
  factory :author do
    given_name { Faker::Name.first_name }
    family_name { Faker::Name.last_name }
  end
end
