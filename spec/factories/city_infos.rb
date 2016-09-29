# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :city_info do
  	city "Chicago"
  	state "Illinois"
  	country "US"
  	upperRightLat 42.024814
  	upperRightLng -87.526917
  	lowerLeftLat 41.640078
	lowerLeftLng -87.947145
  end
end