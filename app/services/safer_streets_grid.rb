class SaferStreetsGrid

  def initialize(cache)
    @cache = cache
  end

  # @param city [City] City name
  # @return [Hash]
  def get_city_feature(city)
    data = @cache.get_value(city_feature_key(city))
    data[data["Key"]] if data
  end

  def get_grid_index(city, city_feature, lat, lng)
		sw_lat = city.south_west.y
		sw_lng = city.south_west.x

    grid_distance = city_feature["distanceBetweenCells"] # in km
    row_dimension = city_feature["rowDimension"]
    col_dimension = city_feature["colDimension"]

    row_distance_from_bottom = CoordinateCalculator.distance(lat, lng, sw_lat, lng)
    row_index = (row_dimension - 1) - (row_distance_from_bottom / grid_distance).floor

    col_distance_from_left = CoordinateCalculator.distance(lat, lng, lat, sw_lng)
    col_index = (col_distance_from_left / grid_distance).floor.to_i

    puts ">>> BEGIN GRID INDEX"
    puts city.name, lat, lng, row_index.to_i, col_index.to_i
    puts "<<< END GRID INDEX"

    [row_index.to_i, col_index.to_i]
  end

  def get_grid_by_index(city, start_row, start_col, end_row, end_col)
    keys = []
    for i in start_row..end_row
      for j in start_col..end_col
        keys << crime_grid_key(city, i, j)
      end
    end

    tiles = @cache.batch_get_values(keys)
    tiles.sort! do |a, b|
      a_row = 0
      a_col = 0
      b_row = 0
      b_col = 0

      re = /.*_(\d+)_(\d+)$/
      if (a["Key"] =~ re)
        a_row = $1.to_i
        a_col = $2.to_i
      end

      if (b["Key"] =~ re)
        b_row = $1.to_i
        b_col = $2.to_i
      end

      result = (a_row <=> b_row)
      result = (a_col <=> b_col) if (result == 0)
      result
    end

    tiles.map { |o| o[o["Key"]] }.each_slice(end_col - start_col + 1).to_a
  end

  def slice_grid_and_flatten(grid, grid_div_by)
    n_row = grid.length
    n_col = grid[0].length
    tiles = grid.flatten

    result = Array.new(n_row * n_col * grid_div_by * grid_div_by)
    for pos in 0..tiles.length-1
      data = tiles[pos]

      y0 = data["crimeCoordinate"]["topLeftLatitude"]     # top
      y1 = data["crimeCoordinate"]["btmRightLatitude"]    # bottom

      x0 = data["crimeCoordinate"]["topLeftLongitude"]    # left
      x1 = data["crimeCoordinate"]["btmRightLongitude"]   # right

      for index in 0..(grid_div_by * grid_div_by - 1)
        new_pos = flatten_index(n_row, n_col, pos, grid_div_by, index)
        new_data = data.deep_dup

        old_row, old_col = row_col(n_row, n_col, pos)

        new_data["crimeCoordinate"]["btmRightLatitude"] = get_lat(y0, y1, grid_div_by, index, :bottom)
        new_data["crimeCoordinate"]["btmRightLongitude"] = get_lng(x0, x1, grid_div_by, index, :right)
        new_data["crimeCoordinate"]["centerLatitude"] = get_lat(y0, y1, grid_div_by, index, :center)
        new_data["crimeCoordinate"]["centerLongitude"] = get_lng(x0, x1, grid_div_by, index, :center)
        new_data["crimeCoordinate"]["topLeftLatitude"] = get_lat(y0, y1, grid_div_by, index, :top)
        new_data["crimeCoordinate"]["topLeftLongitude"] = get_lng(x0, x1, grid_div_by, index, :left)
        new_data["crimeCoordinate"]["latitude"] = new_data["crimeCoordinate"]["topLeftLatitude"]
        new_data["crimeCoordinate"]["longitude"] = new_data["crimeCoordinate"]["topLeftLongitude"]

        # puts "SLICE #{old_row},#{old_col} / #{n_row},#{n_col} | #{pos} > #{index}: #{new_pos}: #{new_data["crimeCoordinate"]["btmRightLatitude"]}"

        result[new_pos] = new_data
      end
    end

    result
  end

  def find_row_col_from_flattened_grid(tiles, lat, lng, n_row, n_col)
    index = tiles.find_index do |t|
      lat >= t["crimeCoordinate"]["btmRightLatitude"] and lat <= t["crimeCoordinate"]["topLeftLatitude"] and
        lng <= t["crimeCoordinate"]["btmRightLongitude"] and lng >= t["crimeCoordinate"]["topLeftLongitude"]
    end

    unless index
      temp = [[lat, lng]]
      tiles.each { |t|
        temp << [t["crimeCoordinate"]["topLeftLatitude"], t["crimeCoordinate"]["topLeftLongitude"]]
        temp << [t["crimeCoordinate"]["centerLatitude"], t["crimeCoordinate"]["centerLongitude"]]
        temp << [t["crimeCoordinate"]["btmRightLatitude"], t["crimeCoordinate"]["btmRightLongitude"]]
      }
      puts GoogleMapsService::Polyline.encode(temp)
    end

    return row_col(n_row, n_col, index)
  end

  private
    def city_feature_key(city)
      "citygridfeatures_#{normalize_city_name(city)}"
    end

    def crime_grid_key(city, row, col)
      "crimegrid_#{normalize_city_name(city)}_#{row}_#{col}"
    end

    def normalize_city_name(city)
      city.name.parameterize("_")
    end

    def row_col(n_row, n_col, pos)
      [pos / n_col, pos % n_col]
    end

    def flatten_index(n_row, n_col, pos, grid_div_by, index)
      old_row, old_col = row_col(n_row, n_col, pos)
      return old_row * n_col * grid_div_by * grid_div_by +    # Full tile before
        (index / grid_div_by) * n_col * grid_div_by +         # Full part-row before
        old_col * grid_div_by +                               # Full part-column before
        index % grid_div_by                                   # Index
    end

    def get_lat(x0, x1, grid_div_by, index, type)
      d = (x1 - x0).to_f / grid_div_by
      x0 + ((index / grid_div_by) + get_lat_lng_factor(type)) * d
    end

    def get_lng(y0, y1, grid_div_by, index, type)
      d = (y1 - y0).to_f / grid_div_by
      y0 + ((index % grid_div_by) + get_lat_lng_factor(type)) * d
    end

    def get_lat_lng_factor(type)
      case type
      when :left, :top
        return 0
      when :center
        return 0.5
      when :right, :bottom
        return 1
      end
    end
end
