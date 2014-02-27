# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :group do
    sequence :name do |n|
      "East #{n}"
    end
    display true
    from 'no-reply@houstonize.com'
  end
end
