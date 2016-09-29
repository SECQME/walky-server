# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :safer_streets_request do
  	id 3
  	userid "60-122053051"
    city "Petaling Jaya"
    state "Selangor"
    country "Mal"
    postcode "47800"
    requestTime "2015-01-28 07:50:13"
  end
end
