class RouteRatingService

  RGEO_FACTORY = RGeo::Geos.factory

  def initialize(bounding_box, expansion_factor = 0.01)
    @bounding_box = expand_bounding_box(normalize_bounding_box(bounding_box), expansion_factor)
    setup_cities
    setup_zones
    setup_grids
    @cities.count
  end

  def rate(line)
    points = normalize_line(line)
    points = refine_points(points, @minimum_grid_size / 2) if @minimum_grid_size
    points.map do |point|
      zone_rating = rate_point_by_zone(point)
      if zone_rating then
        zone_rating
      else
        rate_point_by_grid(point)
      end
    end
  end

  def logger
    @logger ||= Rails.logger
  end

  def logger=(logger)
    @logger = logger
  end

  protected

  def normalize_bounding_box(bounding_box)
    if bounding_box.kind_of?(City) then
      city = bounding_box
      {
        south_west: {lat: city.south_west.y, lng: city.south_west.x},
        north_east: {lat: city.north_east.y, lng: city.north_east.x}
      }
    elsif bounding_box.kind_of?(Hash) and bounding_box.has_key?(:southwest) and bounding_box.has_key?(:northeast)
      {
        south_west: bounding_box[:southwest],
        north_east: bounding_box[:northeast]
      }
    else
      bounding_box
    end
  end

  def expand_bounding_box(bounding_box, factor = 0.02)
    {
      south_west: {lat: bounding_box[:south_west][:lat] - factor, lng: bounding_box[:south_west][:lng] - factor},
      north_east: {lat: bounding_box[:north_east][:lat] + factor, lng: bounding_box[:north_east][:lng] + factor}
    }
  end

  def normalize_line(line)
    line = line.geom_way if line.kind_of?(Line)

    if line.respond_to?(:points) then
      line.points
    else
      line.map { |point| RGEO_FACTORY.point(point[:lng], point[:lat]) }
    end
  end

  def refine_points(points, distance)
    result = []
    points.each do |point|
      unless result.first
        result << point
      else
        bearing = nil
        while (GeoFormula.distance(result.last.y, result.last.x, point.y, point.x) > distance)
    			bearing ||= GeoFormula.bearing(result.last.y, result.last.x, point.y, point.x)

    			new_point = GeoFormula.project_point(result.last.y, result.last.x, bearing, distance)
          result << RGEO_FACTORY.point(new_point[:lng], new_point[:lat])
    		end
        result << point
      end
    end
    result
  end

  def format_point(point)
    "(%.6f, %.6f)" % [point.y, point.x]
  end

  def rate_point_by_zone(point)
    zone = find_zone(point)
    if zone then
      {
        lat: point.y,
        lng: point.x,
        city_id: zone.city_id,
        row: nil,
        col: nil,
        zone_id: zone.id,
        daytime_safety_level: SafetyLevelConverter.from_key(zone.zone_type),
        dark_safety_level: SafetyLevelConverter.from_key(zone.zone_type)
      }
    end
  end

  def find_zone(point)
    @zones.find { |zone| zone.area.contains?(point) }
  end

  def rate_point_by_grid(point)
    grid = find_grid(point)
    if grid then
      {
        lat: point.y,
        lng: point.x,
        city_id: grid.city_id,
        row: grid.row,
        col: grid.col,
        zone_id: nil,
        daytime_safety_level: SafetyLevelConverter.from_int(grid.daytime_safety_level),
        dark_safety_level: SafetyLevelConverter.from_int(grid.dark_safety_level)
      }
    else
      {
        lat: point.y,
        lng: point.x,
        city_id: nil,
        row: nil,
        col: nil,
        zone_id: nil,
        daytime_safety_level: SafetyLevelConverter.unknown,
        dark_safety_level: SafetyLevelConverter.unknown
      }
    end
  end

  def find_grid(point)
    city = find_city(point)
    if city then
      row, col = GeoFormula.to_row_col(city, point.y, point.x)
      @grids[city.id][row, col]
    else
      nil
    end
  end

  def find_city(point)
    @cities.find{ |c| c.area.contains?(point) }
  end

  def setup_cities
    @cities = City.where(coming_soon: false).intersect_with_bounds(@bounding_box[:south_west][:lat], @bounding_box[:south_west][:lng], @bounding_box[:north_east][:lat], @bounding_box[:north_east][:lng]).all
    logger.info "Cover #{@cities.count} cities"
    @cities
  end

  def setup_zones
    @zones = Zone.where(city: @cities).intersect_with_bounds(@bounding_box[:south_west][:lat], @bounding_box[:south_west][:lng], @bounding_box[:north_east][:lat], @bounding_box[:north_east][:lng]).all
    logger.info "Cover #{@zones.count} zones"
    @zones
  end

  def setup_grids
    @grids = SparseArray.new
    @cities.each do |c|
      @grids[c.id] = create_grids(c)
    end
    @minimum_grid_size = (@cities.min_by { |city| city.grid_size }).grid_size unless @cities.empty?
    @grids
  end

  def create_grids(city)
    grids = SparseMatrix::YaleSparseMatrix.new

    CrimeGrid.where(city: city).intersect_with_bounds(@bounding_box[:south_west][:lat], @bounding_box[:south_west][:lng], @bounding_box[:north_east][:lat], @bounding_box[:north_east][:lng]).each do |cg|
      grids[cg.row, cg.col] = cg
    end

    logger.debug "City #{city.id} (#{city.name}) has #{grids.a.size}"

    grids
  end
end
