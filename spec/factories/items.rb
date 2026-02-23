FactoryBot.define do
  factory :item do
    user
    title { Faker::Lorem.sentence }
    action_type { :read }
    time_bucket { :five }
    energy { :low }
    status { :active }
  end
end
