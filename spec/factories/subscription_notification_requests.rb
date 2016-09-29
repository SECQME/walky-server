# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :subscription_notification_request do
  	id 1
  	email "edward@watchovermeapp.com"
    city "San Francisco"
    state "California"
    country "US"
    requestTime "2015-04-10 15:25:18"
  end
end
