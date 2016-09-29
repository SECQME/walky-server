require 'google_direction_api'
require 'safer_streets_api'

class SafeDirectionController < BaseApiController

  def index
    # direction = GoogleDirectionsApi.new(
    #   '-31.916452, 127.505556',
    #   '-31.908112, 127.183891')
	direction = GoogleDirectionsApi.new(
      '41.916702, -87.746073',
      '41.909609, -87.746073')
    direction.json['routes'].each do |route|
      safety_data = SaferStreetsApi.new().check_grid_crime_report(route['overview_polyline']['decoded_points'], "Chicago")
      route['overview_rating'] = safety_data['rating']
      route['overview_polyline']['decoded_points'] = safety_data['steps']
      route['legs'].each do |leg|
        leg['steps'].each do |step|
          step_safety_data = SaferStreetsApi.new().check_grid_crime_report(step['polyline']['decoded_points'], "Chicago")
          step['ployline_rating'] = step_safety_data['rating']
          step['polyline']['decoded_points'] = step_safety_data['steps']
        end
      end
    end
    render json: direction.json
  end

end
