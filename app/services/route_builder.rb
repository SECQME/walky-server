class RouteBuilder

  WALKING_FACTOR = 761.71875 # sec / km, derived from Google Maps Direction

  def build(origin_lat, origin_lng, destination_lat, destination_lng, lines)
    overview_polyline_points = []

    steps = []
    step_polyline_points = []

    n_lines = 0

    first = true
    prev_line = nil
    prev_reversed = nil
    direction = nil
    source_lat = nil
    source_lng = nil

    lines.each do |line|
      n_lines += 1
      ls = line.geom_way

      if first
        if GeoFormula.distance(origin_lat, origin_lng, ls.points.first.y, ls.points.first.x) > GeoFormula.distance(origin_lat, origin_lng, ls.points.last.y, ls.points.last.x)
          reversed = true
          points = ls.points.reverse
        else
          points = ls.points
        end
        direction = heading_direction(line, reversed)
      else
        first_point = ls.points.first
        unless source_lat == first_point.y && source_lng == first_point.x
          reversed = true
          points = ls.points.reverse
        else
          points = ls.points
        end
      end

      new_points = points.map { |p| { lat: p.y, lng: p.x } }

      if first or prev_line.nil? || line.osm_id == prev_line.osm_id || line.osm_name == prev_line.osm_name
        merge_points(step_polyline_points, new_points)
      else
        steps << create_step(step_polyline_points, direction)

        n_lines = 0
        direction = turn_direction(prev_line, prev_reversed, line, reversed)
        step_polyline_points = []
        merge_points(step_polyline_points, new_points)
      end

      source_lat = points.last.y
      source_lng = points.last.x
      merge_points(overview_polyline_points, new_points)
      prev_line = line
      prev_reversed = reversed
      first = false
    end

    steps << create_step(step_polyline_points, direction)

    total_distance = steps.reduce(0) { |distance, step| distance + step[:distance][:value] } / 1000.0
    total_duration = steps.reduce(0) { |duration, step| duration + step[:duration][:value] }

    {
      bounds: bounding_box(overview_polyline_points),
      copyrights: "Map data ©2016 Open Street Map and Watch Over Me",
      legs: [
        {
          distance: create_distance(total_distance),
          duration: create_duration(total_duration),
          start_address: "",
          start_location: steps.first[:start_location],
          end_address: "",
          end_location: steps.last[:end_location],
          steps: steps
        }
      ],
      overview_polyline: {
        points: GoogleMapsService::Polyline.encode(overview_polyline_points)
      },
      summary: "",
      warnings: ["Walking directions are in beta. Use caution – This route may be missing sidewalks or pedestrian paths."],
      waypoint_order: [],
      source: "walky"
    }
  end

  def merge_points(array, points)
    if array.length > 1
      last_points = array.last
      if (last_points[:lat] == points.first[:lat] and last_points[:lng] == points.first[:lng])
        points.shift
      end
    end
    array.push(*points)
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

  def create_step(points, direction)
    distance = calculate_distance(points)
    duration = (distance * WALKING_FACTOR).ceil

    {
      distance: create_distance(distance),
      duration: create_duration(duration),
      end_location: {
        lat: points.last[:lat],
        lng: points.last[:lng],
      },
      html_instructions: direction[:html_instructions],
      maneuver: direction[:maneuver],
      polyline: {
        points: GoogleMapsService::Polyline.encode(points)
      },
      start_location: {
        lat: points.first[:lat],
        lng: points.first[:lng],
      }
    }
  end

  def calculate_distance(points)
    distance = 0.0
    prev_point = nil
    points.each do |point|
      if prev_point then
        distance += CoordinateCalculator.distance(prev_point[:lat], prev_point[:lng], point[:lat], point[:lng])
      end
      prev_point = point
    end
    distance
  end

  def create_distance(distance_in_km)
    distance = (distance_in_km * 1000).ceil
    distance_in_miles = (distance * 0.000621371).round(1)
    distance_in_miles = 0.1 if distance_in_miles < 0.1
    { text: "#{distance_in_miles} mi", value: distance }
  end

  def create_duration(duration_in_sec)
    duration_in_minutes = (duration_in_sec / 60).round
    duration_in_minutes = 1 if duration_in_minutes < 1
    { text: "#{duration_in_minutes} #{duration_in_minutes > 1 ? "mins" : "min"}", value: duration_in_sec }
  end

  def heading_direction(line, reversed, format = :html)
    ls = line.geom_way
    if (reversed) then
      points = ls.points.reverse
    else
      points = ls.points
    end
    s_point = points.first
    e_point = points.last
    bearing = CoordinateCalculator.bearing(s_point.y, s_point.x, e_point.y, e_point.x)

    case bearing
    when 23..67
      compass_direction = "north east"
    when 67..113
      compass_direction = "east"
    when 113..158
      compass_direction = "south east"
    when 158..202
      compass_direction = "south"
    when 202..248
      compass_direction = "south west"
    when 248..292
      compass_direction = "west"
    when 292..336
      compass_direction = "north west"
    else
      compass_direction = "north"
    end

    unless (line.osm_name.blank?)
      direction = "Head <b>#{compass_direction}</b> on <b>#{line.osm_name}</b>"
    else
      direction = "Head <b>#{compass_direction}</b>"
    end

    {
      html_instructions: direction
    }
  end

  def turn_direction(prev_line, prev_reversed, line, reversed)
    prev_ls = prev_line.geom_way
    if (prev_reversed) then
      prev_points = prev_ls.points.reverse
    else
      prev_points = prev_ls.points
    end
    prev_s_point = prev_points.first
    prev_e_point = prev_points.last
    prev_final_bearing = CoordinateCalculator.bearing(prev_s_point.y, prev_s_point.x, prev_e_point.y, prev_e_point.x)

    current_ls = line.geom_way
    if (reversed) then
      current_points = current_ls.points.reverse
    else
      current_points = current_ls.points
    end
    current_s_point = current_points.first
    current_e_point = current_points.last
    current_start_bearing = CoordinateCalculator.bearing(current_s_point.y, current_s_point.x, current_e_point.y, current_e_point.x)

    angle = (current_start_bearing - prev_final_bearing) % 360

    case angle
    when 23..67
      direction = "Turn <b>sharp right</b>"
      maneuver = "turn-sharp-right"
    when 67..113
      direction = "Turn <b>right</b>"
      maneuver = "turn-right"
    when 113..158
      direction = "Turn <b>slight right</b>"
      maneuver = "turn-slight-right"
    when 158..180
      direction = "Make a <b>U-turn</b>"
      maneuver = "uturn-right"
    when 180..202
      direction = "Make a <b>left U-turn</b>"
      maneuver = "uturn-left"
    when 202..248
      direction = "Turn <b>sharp left</b>"
      maneuver = "turn-sharp-left"
    when 248..292
      direction = "Turn <b>left</b>"
      maneuver = "turn-left"
    when 292..336
      direction = "Turn <b>slight left</b>"
      maneuver = "turn-slight-left"
    else
      direction = "Go <b>straight</b>"
      maneuver = "straight"
    end

    unless (line.osm_name.blank?)
      direction = "#{direction} onto <b>#{line.osm_name}</b>"
    end

    {
      html_instructions: direction,
      maneuver: maneuver
    }
  end
end
