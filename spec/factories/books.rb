FactoryBot.define do
  factory :book do
    title { Faker::Book.title  }
    subtitle { Faker::Lorem.sentence }
    isbn_10 { Faker::Code.isbn.gsub('-','') }
    isbn_13 { Faker::Code.isbn(13).gsub('-','') }
    description { Faker::Lorem.paragraph }
    released_on { Faker::Date.forward }
    publisher
    author
  end
end
