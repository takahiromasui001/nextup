FactoryBot.define do
  factory :user do
    provider { 'google_oauth2' }
    sequence(:uid) { |n| "uid_#{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    name { Faker::Name.name }
  end
end
