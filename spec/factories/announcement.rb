# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :announcement do
    sequence :text do |n|
      "Text #{n}"
    end    
  end
end