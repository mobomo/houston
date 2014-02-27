# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :project do
    client "FavoriteClient"
    name "SOW1 - Web App"
    hours_budget 100
    hours_used 80
    rate 175
    date_kickoff 1.day.ago
  end
  trait :active do
    date_kickoff 1.day.ago
    date_delivered 1.day.from_now
  end

  trait :inactive do
    date_kickoff 1.day.from_now
  end

  trait :internal do
    client "Internal"
  end
end
