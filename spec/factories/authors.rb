FactoryBot.define do
  factory :author do
    given_name { Faker::Name.first_name }
    family_name { Faker::Name.last_name }
  end

  trait :with_book do
    after :create do |author|
      create :book, author: author
    end
  end
end
