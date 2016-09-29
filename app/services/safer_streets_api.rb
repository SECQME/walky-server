require 'api_service'
require 'coordinate_calculator'

class SaferStreetsApi
	SS_BASE_URL = APP_CONFIG['ss_base_url']
	URL_GRID_CRIME_REPORT = APP_CONFIG['url_grid_crime_report']
	JSON_KEY_LATITUDE = APP_CONFIG['json_key_latitude'].to_sym
	JSON_KEY_LONGITUDE = APP_CONFIG['json_key_longitude'].to_sym
	JSON_KEY_CITY = APP_CONFIG['json_key_city'].to_sym
	JSON_KEY_SAFETY_RATING = APP_CONFIG['json_key_safety_rating'].to_sym
	JSON_KEY_RATING = APP_CONFIG['json_key_rating'].to_sym
	JSON_KEY_STEPS = APP_CONFIG['json_key_steps'].to_sym
	DISTANCE_BTW_POINT = 0.25

	def check_grid_crime_report(route_points, city_name)

		body = {
			JSON_KEY_CITY => city_name,
			JSON_KEY_STEPS => self.refine_route(route_points)
		}

		grid_crime_report = ApiService.new().post_api(SS_BASE_URL + URL_GRID_CRIME_REPORT, body)

		grid_crime_report
	end

	def refine_route(route_points)
		new_route_points = []
		temp_lat = nil
		temp_lng = nil
		route_points.each do |point|
			unless (temp_lat and temp_lng)
				temp_lat = point[:latitude]
				temp_lng = point[:longitude]
				new_route_points << {
					JSON_KEY_LATITUDE => point[:latitude],
					JSON_KEY_LONGITUDE => point[:longitude]
				}
			else
				new_route_points.push(*points_between(temp_lat,temp_lng,point[:latitude],point[:longitude], DISTANCE_BTW_POINT))

				temp_lat = point[:latitude]
				temp_lng = point[:longitude]
			end
		end
		# p new_route_points
		new_route_points
	end

	private

	def points_between(lat1, lng1, lat2, lng2, new_point_distance)
		new_points = []

		while (CoordinateCalculator.distance(lat1, lng1, lat2, lng2) > new_point_distance)
			bearing ||= CoordinateCalculator.bearing(lat1, lng1, lat2, lng2)

			new_point = CoordinateCalculator.new_coordinate(lat1, lng1, bearing, new_point_distance)
			new_points << {
				JSON_KEY_LATITUDE => new_point[:latitude],
				JSON_KEY_LONGITUDE => new_point[:longitude]
			}
			lat1 = new_point[:latitude]
			lng1 = new_point[:longitude]
		end

		new_points << {
			JSON_KEY_LATITUDE => lat2,
			JSON_KEY_LONGITUDE => lng2
		}
		new_points
	end
end
