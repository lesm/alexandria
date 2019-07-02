FactoryBot.define do
  factory :publisher do
    name { Faker::Name.name }
  end

  trait :with_p_book do
    after(:create) do |publisher|
      create :book, publisher: publisher
    end
  end
end
