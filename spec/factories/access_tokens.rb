FactoryBot.define do
  factory :access_token do
    token_digest { nil }
    accessed_at { "2019-08-02 20:16:25" }
    user
    api_key
  end
end
