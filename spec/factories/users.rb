FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { 'password' }
    given_name { Faker::Name.first_name }
    family_name { Faker::Name.last_name }
    role { :user }

    trait :confirmation_redirect_url do
      confirmation_token { Faker::Alphanumeric.alphanumeric(10) }
      confirmation_redirect_url { 'https://www.google.com' }
    end

    trait :confirmation_no_redirect_url do
      confirmation_token { Faker::Alphanumeric.alphanumeric(10) }
      confirmation_redirect_url { nil }
    end

    trait :reset_password do
      reset_password_token { Faker::Alphanumeric.alphanumeric(8) }
      reset_password_redirect_url { 'http://example.com?some=params' }
      reset_password_sent_at { Time.current }
    end

    trait :reset_password_no_params do
      reset_password_token { Faker::Alphanumeric.alphanumeric(8) }
      reset_password_redirect_url { 'http://example.com' }
      reset_password_sent_at { Time.current }
    end

    #last_logged_in_at { "2019-07-10 15:11:42" }
    #confirmed_at { "2019-07-10 15:11:42" }
    #confirmation_sent_at { "2019-07-10 15:11:42" }
  end

  factory :admin, class: User do
    email { 'admin@example.com' }
    password { 'password' }
    given_name { 'Super' }
    family_name { 'Admin' }
    confirmed_at { Time.now }
    role { :admin }
  end
end
