# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :crime_streets_rating do
  	crimeStreetsID "16125"
  	city "Petaling Jaya"
    state "Selangor"
    country "MY"
    postcode 47410
    avgUserStreetsSafetyRating 3
    crimeStreetsRating "MODERATE"
    gridAddress "[{'colIndex':17,'rowIndex':6}]"
    createdDate "2015-04-16 01:15:25"
    updatedDate "2015-04-16 01:15:25"
  end
end