# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :leave_request do
    checked_with_supervisor 'Yes, I checked with my supervisor'
    reason_for_leaving 'Gotta hop off the grid occasionally'
    sequence(:start_date) { |n| Time.now + n.days }
    sequence(:end_date)   { |n| Time.now + n.days }
    association :user, :regular_user
  end
  trait :admin_leave_request do
    association :user, :super_admin
  end
end
