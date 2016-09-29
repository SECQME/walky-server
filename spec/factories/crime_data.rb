# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :crime_datum do
  	id 1
  	crimeCaseID "SODA_CHICAGO_HW590218"
	crimeType "BATTERY"
	address "020XX W 79TH ST, type:SMALL RETAIL STORE, district:006, community_area:71"
	crimeDate "2014-01-01 04:48:00"
	timeZone "Central Standard Time"
	note "SIMPLE, arrest:true"
	latitude 41.750335146
	longitude -87.673745265
	reportDate "2014-01-01 22:51:19"
	source "http://data.cityofchicago.org//resource/ijzp-q8t2.json?ID=9446519"
	city "Chicago"
	state "Illinois"
	country "US"
	crimeWeight 38.1
  end
end