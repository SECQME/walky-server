# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_street_safety_rating_log do
  	id 2
  	crimeStreetsID "Lebuhraya Sprint"
    latitude 3.133701641305574
    longitude 101.6074836265444
    userStreetSafetyRating 1
    accuracy 65
    userRatingTime "2015-01-28 08:22:57"
    userid "60-187620025"
    city "Petaling Jaya"
    state "Selangor"
    country "Mal"
    postcode 47800          
  end
end
