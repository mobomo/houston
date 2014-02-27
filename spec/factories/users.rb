FactoryGirl.define do
  factory :user do
    name "Gary Flandro"
    email "gary@houstonize.com"
    group
    role 'Regular'
  end
  trait :rails_dev do
    skills FactoryGirl.create_list(:skill, 1, name: 'Rails')
  end
  trait :js_dev do
    skills FactoryGirl.create_list(:skill, 1, name: 'Javascript')
  end
  trait :super_admin do
    role 'SuperAdmin'
    name 'The Bomb'
  end
  trait :regular_user do
    role 'Regular'
  end
  trait :has_leave_requests do
    leave_requests { 6.times.map { FactoryGirl.create(:leave_request) } }
  end
  trait :has_admin_leave_requests do
    leave_requests { 6.times.map { FactoryGirl.create(:leave_request, :admin_leave_request) } }
  end
end
