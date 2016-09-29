# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :feature do
    name "Notify when incident is tagged near your home"
    description "Get push notifications when an incident occurs within a 1km radius of your home"
    total_votes 10
    completed false
    archived false
    notified false
  end
end
