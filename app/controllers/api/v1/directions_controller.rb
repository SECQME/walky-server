require 'google_direction_api'
require 'safer_streets_api'
require 'coordinate_calculator'
require 'walky-astar/grid'

class Api::V1::DirectionsController < ApplicationController
  respond_to :json

  def routes
    from_param = params[:from].split(",").map { |v| v.to_f }
    to_param = params[:to].split(",").map { |v| v.to_f }
    datetime_param = params[:datetime]

    from = Graticule::Location.new(latitude: from_param[0], longitude: from_param[1])
    to = Graticule::Location.new(latitude: to_param[0], longitude: to_param[1])
    straight_distance = Graticule::Distance::Haversine.distance(from, to, :kilometers)

    if straight_distance > 10.0
      render status: 422, json: { "status" => "distance_error", :error_description => "distance_warning_10km", :routes => [] }
    else
      routes = find_route(from_param, to_param, params[:datetime])

      if straight_distance > 5.0
        render json: { :status => "distance_warning", :error_description => "distance_warning_5km" , :routes => routes }
      else
        render json: { :status => "ok", :error_description => nil , :routes => routes }
      end
    end
  end

  private
    def recommended_route(city, day_time, origin_lat, origin_lng, destination_lat, destination_lng)
      return [] unless city

      city_feature = $saferstreets_grid.get_city_feature(city)
      return [] unless city_feature

      origin_row, origin_col = $saferstreets_grid.get_grid_index(city, city_feature, origin_lat, origin_lng)
      destination_row, destination_col = $saferstreets_grid.get_grid_index(city, city_feature, destination_lat, destination_lng)

      # HACK: Expand the grid
      origin_row = origin_row - 1 if origin_row > 0 and origin_row <= destination_row
      destination_row = destination_row - 1 if destination_row > 0 and origin_row >= destination_row

      top_row, bottom_row = [origin_row, destination_row].minmax
      left_col, right_col = [origin_col, destination_col].minmax

      # HACK: Limitation of DynamoDB
      return [] if ((bottom_row - top_row + 1) * (right_col - left_col + 1)) > 100

      original_grid = $saferstreets_grid.get_grid_by_index(city, top_row, left_col, bottom_row, right_col)
      grid_div_by = 3
      refined_tiles = $saferstreets_grid.slice_grid_and_flatten(original_grid, grid_div_by)

      n_row = (bottom_row - top_row + 1) * grid_div_by
      n_col = (right_col - left_col + 1) * grid_div_by

      i = 0
      levels = refined_tiles.map do |data|
        score = 1
        case day_time
        when 0
          score = safety_level_to_score(data["darkSafetyReport"]["safetyRating"]) if data["darkCrimeTrend"]
        when 1
          score = safety_level_to_score(data["daytimeSafetyReport"]["safetyRating"]) if data["daytimeCrimeTrend"]
        end
        score
      end
      centers = refined_tiles.map do |data|
        {lat: data["crimeCoordinate"]["centerLatitude"], lng: data["crimeCoordinate"]["centerLongitude"]}
      end

      origin_row_refined, origin_col_refined = $saferstreets_grid.find_row_col_from_flattened_grid(refined_tiles, origin_lat, origin_lng, n_row, n_col)
      destination_row_refined, destination_col_refined = $saferstreets_grid.find_row_col_from_flattened_grid(refined_tiles, destination_lat, destination_lng, n_row, n_col)
      grid = Walky::AStar::Grid.new 0, 0, n_row-1, n_col-1, levels

      # Only allow diagonal movement for grid dimension more than 6 small grid (> 1.5 km)
      grid.diagonal_neighbours = (n_row > 6 and n_col > 6)

      puts ">>> BEGIN PathFinder"
      finder = Walky::AStar::PathFinder
        .using_euclidean_distance_strategy
        .from(grid.get_tile(origin_row_refined, origin_col_refined))
        .to(grid.get_tile(destination_row_refined, destination_col_refined))
      route = finder.next_route
      puts "<<< END PathFinder"

      waypoints = []
      if (route)
        path = route.path
        path.each_with_index do |item, index|
          row = item.row
          col = item.col
          linear_index = (row * n_col) + col

          next if (index == 0 or index == path.length - 1)
          next if (path[index-1].row == path[index+1].row) or (path[index-1].col == path[index+1].col)
          next if (path[index-1].row - path[index+1].row).abs == (path[index-1].col - path[index+1].col).abs

          waypoints << centers[linear_index]
        end
      end

      waypoints.unshift({lat: origin_lat, lng: origin_lng})
      waypoints.push({lat: destination_lat, lng: destination_lng})

      logger.debug "Origin: #{origin_lat}, #{origin_lng}"
      logger.debug "Destination: #{destination_lat}, #{destination_lng}"
      logger.debug "Original waypoints: #{GoogleMapsService::Polyline.encode(waypoints)}"

      # HACK: Skip if the waypoints more than 23
      return [] if waypoints.length > 23

      routes = [];
      routes = GoogleMapsService::Client.instance.directions(
        {lat: origin_lat, lng: origin_lng},
        {lat: destination_lat, lng: destination_lng},
        :language => :en,
        :alternatives => :false,
        :mode => :walking,
        :waypoints => convert_via_waypoints(waypoints)
      )

      logger.debug "Original result: #{routes[0][:overview_polyline][:points]}" unless routes.empty?

      return [] if routes.empty?

      points = GoogleMapsService::Polyline.decode(routes[0][:overview_polyline][:points])
      refined_waypoints = refine_waypoints(points)
      refined_routes = GoogleMapsService::Client.instance.directions(
        {lat: origin_lat, lng: origin_lng},
        {lat: destination_lat, lng: destination_lng},
        :language => :en,
        :alternatives => :false,
        :mode => :walking,
        :waypoints => convert_via_waypoints(refined_waypoints)
      )

      logger.debug "Refined waypoints: #{GoogleMapsService::Polyline.encode(refined_waypoints)}"
      logger.debug "Refined routes: #{refined_routes[0][:overview_polyline][:points]}" if refined_routes.any?

      refined_routes
    end

    def refine_waypoints(path, tolerance = 167.0)
      return path if path and path.length < 2

      tolerance = Sphericalc::S1Angle.from_actual_distance(tolerance)
      result = []

      # This is modified Reumann-Witkam polyline simplification algorithm
      i_key = 0
      result << path[i_key]
      while i_key+1 < path.length do
        result << path[i_key+1]
        a = Sphericalc::S2LatLng.from_degrees(path[i_key][:lat], path[i_key][:lng]).to_point
        b = Sphericalc::S2LatLng.from_degrees(path[i_key+1][:lat], path[i_key+1][:lng]).to_point
        a_cross_b = Sphericalc::S2.robust_cross_prod(a, b)

        i_inspect = i_key + 2
        while i_inspect < path.length do
          current_waypoint = path[i_inspect]
          current_s2point = Sphericalc::S2LatLng.from_degrees(current_waypoint[:lat], current_waypoint[:lng]).to_point

          distance_to_line = Sphericalc::S2EdgeUtil.get_perpendicular_distance(current_s2point, a, b, a_cross_b)
          if (distance_to_line < tolerance)
            if (i_inspect == path.length - 1)
              result << current_waypoint
            end
            i_inspect += 1
          else
            include_candidate = true
            candidate_waypoint = current_waypoint
            candidate_s2point = current_s2point

            # Detect big-U-turn
            i_u_inspect = i_inspect + 1
            while i_u_inspect < path.length do
              current_waypoint = path[i_u_inspect]
              current_s2point = Sphericalc::S2LatLng.from_degrees(current_waypoint[:lat], current_waypoint[:lng]).to_point
              distance_to_line = Sphericalc::S2EdgeUtil.get_perpendicular_distance(current_s2point, a, b, a_cross_b)
              if (distance_to_line < tolerance)
                distance_to_candidate = Sphericalc::S1Angle.from_points(candidate_s2point, current_s2point)
                if (distance_to_candidate < tolerance)
                  i_inspect = i_u_inspect
                  include_candidate = false
                  break
                end
              end
              i_u_inspect += 1
            end

            if include_candidate
              # No big-U-turn
              result.pop
              result << candidate_waypoint
              i_inspect += 1
            end

            break
          end
        end
        i_key = i_inspect
      end

      result.delete_at(result.length - 2) if (result.length >= 3)
      result
    end

    def convert_via_waypoints(waypoints)
      waypoints.each_with_index.map { |v, i|
        if i == 0 or i == (waypoints.length - 1)
          v
        else
          "via:" + GoogleMapsService::Convert.latlng(v)
        end
      }
    end

    def safety_level_to_score(level)
      case(level)
      when 1, "LOW_SAFETY"
        16
      when 0, "MODERATE"
        4
      when -1, "MODERATELY_SAFE"
        1
      else
        raise "Unknown safety level (#{level})"
      end
    end

    def calculate_path_rating(path)
      return 0 unless path and path.length > 0

      rating = 0
      i = 0
      a = Sphericalc::S2LatLng.from_degrees(path[i]["latitude"], path[i]["longitude"])
      for i in 1..(path.length-1)
        b = Sphericalc::S2LatLng.from_degrees(path[i]["latitude"], path[i]["longitude"])
        score = safety_level_to_score(path[i]["safety_rating"])

        distance = a.distance_to(b).to_actual_distance
        path_rating = distance * score

        if score == 1
          rating += path_rating
        else
          rating -= path_rating
        end
        a = b
      end

      rating
    end

    def calculate_path_distance(path)
      return 0 unless path and path.length > 0

      i = 0
      distance = 0
      a = Sphericalc::S2LatLng.from_degrees(path[i]["latitude"], path[i]["longitude"])
      for i in 1..(path.length-1)
        b = Sphericalc::S2LatLng.from_degrees(path[i]["latitude"], path[i]["longitude"])
        distance += a.distance_to(b).to_actual_distance
        a = b
      end

      distance
    end

    def check_crime_day_time datetime_param
      if datetime_param.to_datetime.hour >= 0 && datetime_param.to_datetime.hour < 6
        crime_day_time = 0
      elsif datetime_param.to_datetime.hour >= 6 && datetime_param.to_datetime.hour < 17
        crime_day_time = 1
      elsif datetime_param.to_datetime.hour >= 17 && datetime_param.to_datetime.hour < 24
        crime_day_time = 0
      end
    end

    def find_route from_param, to_param, datetime_param
      origin_city = City.contains(from_param[0], from_param[1]).first
      destination_city = City.contains(to_param[0], to_param[1]).first

      unless datetime_param
        if origin_city
          datetime_param = ActiveSupport::TimeZone[origin_city.city_time_zone].at(Time.now)
        else
          datetime_param = Time.now
        end
      end
      crime_day_time = check_crime_day_time(datetime_param)

      # cached_routes = Route.within_radius(from_param[0], from_param[1], to_param[0], to_param[1], 150, crime_day_time).first
      # return cached_routes.route_response if cached_routes

      google_routes = GoogleMapsService::Client.instance.directions(
        from_param,
        to_param,
        :language => :en,
        :alternatives => :true,
        :mode => :walking
      )
      google_routes.each do |route|
        route[:source] = "google"
      end

      walky_routes = []
      if (origin_city and destination_city and origin_city.id == destination_city.id and not origin_city.coming_soon)
        city_name = origin_city.name
        walky_routes = recommended_route(origin_city, crime_day_time, from_param[0], from_param[1], to_param[0], to_param[1])
        walky_routes.each do |route|
          route[:source] = "walky"
        end

        routes = google_routes + walky_routes
        resolve_safety_level = true
      else
        routes = google_routes
        resolve_safety_level = false
      end

      routes.each do |route|
        route[:overview_polyline][:decoded_points] = GoogleMapsService::Polyline.decode(route[:overview_polyline][:points])
        route[:legs].each do |leg|
          leg[:steps].each do |step|
            step[:polyline][:decoded_points] = GoogleMapsService::Polyline.decode(step[:polyline][:points])
          end
        end
      end

      mappings = {:lat => :latitude, :lng => :longitude}
      routes = routes.rename_keys(mappings)

      if resolve_safety_level
        logger.debug "Resolving routes"
        routes.each do |route|
          safety_data = SaferStreetsApi.new().check_grid_crime_report(route[:overview_polyline][:decoded_points], city_name)
          route[:overview_rating] = calculate_path_rating(safety_data["steps"])
          route[:overview_polyline][:decoded_points] = safety_data["steps"]
          route[:overview_distance] = {
            value: calculate_path_distance(route[:overview_polyline][:decoded_points])
          }

          route[:legs].each do |leg|
            leg[:steps].each do |step|
              step_safety_data = SaferStreetsApi.new().check_grid_crime_report(step[:polyline][:decoded_points], city_name)
              step[:polyline_rating] = calculate_path_rating(step_safety_data["steps"])
              step[:polyline][:decoded_points] = step_safety_data["steps"]
            end
          end
        end

        logger.debug "Removing intolerant routes"
        routes.sort! { |x, y| x[:overview_distance][:value] <=> y[:overview_distance][:value] }
        unless routes.empty?
          tolerance_distance = routes.first[:overview_distance][:value] * 2
          routes = routes.select do |route|
            route[:overview_distance][:value] < tolerance_distance
          end
        end

        logger.debug "Sorting routes"
        routes.sort! { |x, y| x[:overview_rating] <=> y[:overview_rating] }

        # Only choose recommendation route below 10km
        routes = routes.select do |route|
          route[:source] != "walky" or route[:overview_distance][:value] < 10000
        end
      end

      Route.create!(
        start_point: "POINT(#{from_param[1]} #{from_param[0]})",
        end_point: "POINT(#{to_param[1]} #{to_param[0]})",
        route_response: routes,
        crime_day_time: crime_day_time
      ).route_response
    end
end

class Array
  def rename_keys(mapping)
    self.collect do |obj|
      obj.respond_to?(:rename_keys) ? obj.rename_keys(mapping) : obj
    end
  end unless method_defined? :rename_keys
end

class Hash
  def rename_keys(mapping)
    result = {}
    self.map do |k,v|
      mapped_key = mapping[k] ? mapping[k] : k
      result[mapped_key] = v.respond_to?(:rename_keys) ? v.rename_keys(mapping) : v
    end
    result
  end unless method_defined? :rename_keys
end
