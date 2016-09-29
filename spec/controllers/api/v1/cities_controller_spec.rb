require 'spec_helper'

describe Api::V1::CitiesController, :type => :request, :api => true do

  # let(:user) { create(...) }
  # before do
  #   # set auth token
  # end

  describe '/api/v1/cities' do

    context 'when requesting list of cities' do
      # it 'should return list of all cities' do
      #   expect(response_json).to match_array(
      #   [
      #     {
      #       "id": 1,
      #       "name": "Chicago",
      #       "state": "Illinois",
      #       "country": "US",
      #       "lower_left_lat": 41.640078,
      #       "lower_left_lng": -87.947145,
      #       "upper_right_lat": 42.024814,
      #       "upper_right_lng": -87.526917,
      #       "city_time_zone": "America/Chicago",
      #       "crime_day_time_report": false,
      #       "neighbour": null,
      #       "south_west": {
      #         "type": "Point",
      #         "coordinates": [
      #           -87.940101,
      #           41.644286
      #         ]
      #       },
      #       "north_east": {
      #         "type": "Point",
      #         "coordinates": [
      #           -87.523661,
      #           42.023135
      #         ]
      #       },
      #       "coming_soon": false,
      #       "grid_size": 0.25,
      #       "total_rows": 169,
      #       "total_cols": 138
      #     },
      #     {
      #       "id": 2,
      #       "name": "Los Angeles",
      #       "state": "California",
      #       "country": "US",
      #       "lower_left_lat": 33.693769,
      #       "lower_left_lng": -118.672658,
      #       "upper_right_lat": 34.359581,
      #       "upper_right_lng": -118.149434,
      #       "city_time_zone": "America/Los_Angeles",
      #       "crime_day_time_report": false,
      #       "neighbour": null,
      #       "south_west": {
      #         "type": "Point",
      #         "coordinates": [
      #           -118.668176,
      #           33.703652
      #         ]
      #       },
      #       "north_east": {
      #         "type": "Point",
      #         "coordinates": [
      #           -118.155289,
      #           34.337306
      #         ]
      #       },
      #       "coming_soon": false,
      #       "grid_size": 0.25,
      #       "total_rows": 282,
      #       "total_cols": 189
      #     },
      #     {
      #       "id": 4,
      #       "name": "Boston",
      #       "state": "Massachusetts",
      #       "country": "US",
      #       "lower_left_lat": 42.22788,
      #       "lower_left_lng": -71.191155,
      #       "upper_right_lat": 42.40082,
      #       "upper_right_lng": -70.748802,
      #       "city_time_zone": "Etc/GMT-5",
      #       "crime_day_time_report": false,
      #       "neighbour": null,
      #       "south_west": {
      #         "type": "Point",
      #         "coordinates": [
      #           -71.191155,
      #           42.22788
      #         ]
      #       },
      #       "north_east": {
      #         "type": "Point",
      #         "coordinates": [
      #           -70.748802,
      #           42.40082
      #         ]
      #       },
      #       "coming_soon": false,
      #       "grid_size": 0.25,
      #       "total_rows": 76,
      #       "total_cols": 145
      #     },
      #     {
      #       "id": 5,
      #       "name": "Seattle",
      #       "state": "Washington",
      #       "country": "US",
      #       "lower_left_lat": 47.48172,
      #       "lower_left_lng": -122.459696,
      #       "upper_right_lat": 47.734145,
      #       "upper_right_lng": -122.224433,
      #       "city_time_zone": "America/Los_Angeles",
      #       "crime_day_time_report": false,
      #       "neighbour": null,
      #       "south_west": {
      #         "type": "Point",
      #         "coordinates": [
      #           -122.459696,
      #           47.48172
      #         ]
      #       },
      #       "north_east": {
      #         "type": "Point",
      #         "coordinates": [
      #           -122.224433,
      #           47.734145
      #         ]
      #       },
      #       "coming_soon": false,
      #       "grid_size": 0.25,
      #       "total_rows": 112,
      #       "total_cols": 70
      #     },
      #     {
      #       "id": 6,
      #       "name": "Baltimore",
      #       "state": "Maryland",
      #       "country": "US",
      #       "lower_left_lat": 39.197207,
      #       "lower_left_lng": -76.711519,
      #       "upper_right_lat": 39.372206,
      #       "upper_right_lng": -76.529453,
      #       "city_time_zone": "Etc/GMT-5",
      #       "crime_day_time_report": false,
      #       "neighbour": null,
      #       "south_west": {
      #         "type": "Point",
      #         "coordinates": [
      #           -76.711519,
      #           39.197207
      #         ]
      #       },
      #       "north_east": {
      #         "type": "Point",
      #         "coordinates": [
      #           -76.529453,
      #           39.372206
      #         ]
      #       },
      #       "coming_soon": false,
      #       "grid_size": 0.25,
      #       "total_rows": 77,
      #       "total_cols": 62
      #     },
      #     {
      #       "id": 7,
      #       "name": "Oakland",
      #       "state": "California",
      #       "country": "US",
      #       "lower_left_lat": 37.632226,
      #       "lower_left_lng": -122.355881,
      #       "upper_right_lat": 37.885255,
      #       "upper_right_lng": -122.114672,
      #       "city_time_zone": "America/Los_Angeles",
      #       "crime_day_time_report": false,
      #       "neighbour": null,
      #       "south_west": {
      #         "type": "Point",
      #         "coordinates": [
      #           -122.355881,
      #           37.632226
      #         ]
      #       },
      #       "north_east": {
      #         "type": "Point",
      #         "coordinates": [
      #           -122.114672,
      #           37.885255
      #         ]
      #       },
      #       "coming_soon": false,
      #       "grid_size": 0.25,
      #       "total_rows": 113,
      #       "total_cols": 85
      #     },
      #     {
      #       "id": 8,
      #       "name": "Austin",
      #       "state": "Texas",
      #       "country": "US",
      #       "lower_left_lat": 30.098659,
      #       "lower_left_lng": -97.938383,
      #       "upper_right_lat": 30.516863,
      #       "upper_right_lng": -97.561489,
      #       "city_time_zone": "America/Regina",
      #       "crime_day_time_report": false,
      #       "neighbour": null,
      #       "south_west": {
      #         "type": "Point",
      #         "coordinates": [
      #           -97.938383,
      #           30.098659
      #         ]
      #       },
      #       "north_east": {
      #         "type": "Point",
      #         "coordinates": [
      #           -97.561489,
      #           30.516863
      #         ]
      #       },
      #       "coming_soon": false,
      #       "grid_size": 0.25,
      #       "total_rows": 187,
      #       "total_cols": 145
      #     },
      #     {
      #       "id": 3,
      #       "name": "San Francisco",
      #       "state": "California",
      #       "country": "US",
      #       "lower_left_lat": 37.695923,
      #       "lower_left_lng": -122.527036,
      #       "upper_right_lat": 37.837594,
      #       "upper_right_lng": -122.355374,
      #       "city_time_zone": "America/Los_Angeles",
      #       "crime_day_time_report": false,
      #       "neighbour": null,
      #       "south_west": {
      #         "type": "Point",
      #         "coordinates": [
      #           -123.173825,
      #           37.63983
      #         ]
      #       },
      #       "north_east": {
      #         "type": "Point",
      #         "coordinates": [
      #           -122.28178,
      #           37.929824
      #         ]
      #       },
      #       "coming_soon": false,
      #       "grid_size": 0.25,
      #       "total_rows": 129,
      #       "total_cols": 313
      #     }
      #     ]
      #   )
      # end
    end
    # context 'when list is empty' -- not necessary as cities is never an empty table
  end
end
