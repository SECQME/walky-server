class Api::V1::RoutingController < BaseApiController
  before_action :set_origin_and_destination
  before_action :set_day_time

  def routes
    straight_distance = GeoFormula.distance(@origin_lat, @origin_lng, @destination_lat, @destination_lng)
    if straight_distance > 10.0
      render status: 422, json: { status: 'distance_error', error_description: 'distance_warning_10km', routes: [] }
    else
      # unless cached_routes then
        find_routes
        # cache_new_routes
      # end

      if straight_distance > 5.0
        render json: { status: 'distance_warning', error_description: 'distance_warning_5km' , routes: @routes }
      else
        render json: { status: 'ok', error_description: nil , routes: @routes }
      end
    end
  end

  private

  def set_origin_and_destination
    @origin_lat, @origin_lng = params[:from].split(',').map { |v| v.to_f }
    @destination_lat, @destination_lng = params[:to].split(',').map { |v| v.to_f }
  end

  def set_day_time
    @day_time = convert_to_day_time(current_timestamp)
  end

  def convert_to_day_time(ts)
    if ts.to_datetime.hour >= 6 && ts.to_datetime.hour < 17
      EdgeBasedRouteEngine::DAYTIME
    else
      EdgeBasedRouteEngine::DARK
    end
  end

  def current_timestamp
    if @origin_lat and @origin_lng
      origin_city = City.contains(@origin_lat, @origin_lng).take
      return ActiveSupport::TimeZone[origin_city.city_time_zone].at(Time.now) if origin_city
    end

    if @destination_lat and @destination_lng
      destination_city = City.contains(@destination_lat, @destination_lng).take
      return ActiveSupport::TimeZone[destination_city.city_time_zone].at(Time.now) if destination_city
    end

    return Time.now
  end

  def cached_routes
    cache = Route.within_radius(@origin_lat, @origin_lng, @destination_lat, @destination_lng, 50, @day_time).take
    if cache then
      @routes = cache.route_response
    end
    nil # HACK: Disable caching
  end

  def find_routes
    @routes = []
    @routes.push(*walky_routes)
    @routes.push(*google_routes)

    if @routes.any?
      rate_routes!
      sort_routes!

      mappings = {:lat => :latitude, :lng => :longitude}
      @routes = @routes.rename_keys(mappings)
    end
  end

  def walky_routes
    route_engine = EdgeBasedRouteEngine.new(@origin_lat, @origin_lng, @destination_lat, @destination_lng, @day_time)
    if route_engine.origin_edge && route_engine.destination_edge
      lines = route_engine.route

      if lines.any?
        route_builder = RouteBuilder.new
        walky_route = route_builder.build(@origin_lat, @origin_lng, @destination_lat, @destination_lng, lines)

        [walky_route]
      else
        []
      end
    else
      []
    end
  end

  def google_routes
    # return [] # HACK: Disable Google directions

    google_routes = GoogleMapsService::Client.instance.directions(
      [@origin_lat, @origin_lng],
      [@destination_lat, @destination_lng],
      :language => :en,
      :alternatives => :true,
      :mode => :walking
    )
    google_routes.each do |route|
      route[:source] = "google"
    end
  end

  def bounding_box(array)
    nil unless array
    first_point = array.first
    min_x, min_y, max_x, max_y = first_point[:lng], first_point[:lat], first_point[:lng], first_point[:lat]
    array.each do |p|
      min_x = p[:lng] if min_x > p[:lng]
      min_y = p[:lat] if min_y > p[:lat]
      max_x = p[:lng] if max_x < p[:lng]
      max_y = p[:lat] if max_y < p[:lat]
    end
    { northeast: { lat: max_y, lng: max_x }, southwest: { lat: min_y, lng: min_x } }
  end

  def rate_routes!
    setup_route_rating_service
    @routes.each do |route|
      route[:overview_polyline] = polyline_rating(route[:overview_polyline], @day_time)

      # Deprecated, for compability mobile app
      unless route[:overview_polyline][:decoded_points].detect { |p| p[:safety_rating] < -1 } then
        route[:overview_rating] = route[:overview_polyline][:rating]
      end

      route[:legs].each do |leg|
        leg[:steps].each do |step|
          step[:polyline] = polyline_rating(step[:polyline], @day_time)
        end
      end
    end
  end

  def setup_route_rating_service
    points = []
    @routes.each do |route|
      points << route[:bounds][:northeast]
      points << route[:bounds][:southwest]
    end
    @rrs = RouteRatingService.new(bounding_box(points))
  end

  def polyline_rating(polyline, day_time)
    decoded_points = GoogleMapsService::Polyline.decode(polyline[:points])
    rated_points = @rrs.rate(decoded_points)

    first = true
    prev_point = nil
    total_distance = 0.0
    total_rating = 0.0

    safety_level_attribute = :daytime_safety_level if day_time == RouteEngine::DAYTIME
    safety_level_attribute = :dark_safety_level if day_time == RouteEngine::DARK

    result_points = rated_points.map do |point|
      unless first
        distance = GeoFormula.distance(prev_point[:lat], prev_point[:lng], point[:lat], point[:lng])
        rating = (prev_point[safety_level_attribute][:cost] + point[safety_level_attribute][:cost]) * distance / 2

        total_distance += distance
        total_rating += rating
      end

      first = false
      prev_point = point

      {
        lat: point[:lat],
        lng: point[:lng],
        safety_rating: point[safety_level_attribute][:int]
      }
    end

    if total_distance > 0.0 then
      safety_level = SafetyLevelConverter.from_cost(total_rating / total_distance)[:int]
    else
      safety_level = SafetyLevelConverter.unknown[:int]
    end

    {
      points: GoogleMapsService::Polyline.encode(result_points),
      decoded_points: result_points,
      distance: total_distance,
      rating: total_rating / total_distance,
      safety_rating: safety_level
    }
  end

  def sort_routes!
    @routes.sort! do |x, y| x[:overview_polyline][:rating] * x[:overview_polyline][:distance]  <=> y[:overview_polyline][:rating]
      if x[:overview_polyline][:rating] == y[:overview_polyline][:rating]
        x[:overview_polyline][:distance] <=> y[:overview_polyline][:distance]
      else
        x[:overview_polyline][:rating] <=> y[:overview_polyline][:rating]
      end
    end
  end

  def cache_new_routes
    Route.create!(
      start_point: "POINT(#{@origin_lng} #{@origin_lat})",
      end_point: "POINT(#{@destination_lng} #{@destination_lat})",
      route_response: @routes,
      crime_day_time: @day_time
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
