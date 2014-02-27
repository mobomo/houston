FactoryGirl.define do
  factory :schedule do
    week_start Time.zone.end_of_current_week
  end
end
