# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :comment do
    sequence :text do |n|
      "Text #{n}"
    end
    seq 1
    year Date.today.year
  end
end