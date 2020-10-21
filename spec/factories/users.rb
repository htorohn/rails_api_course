FactoryBot.define do
  factory :user do
    sequence(:login) { |n| "jsnow#{n}" }
    name { "John Smith" }
    url { "http://example.com" }
    avatar_url { "http://example.com/avatar" }
    provider { "github" }
  end
end
