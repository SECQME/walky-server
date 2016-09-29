class EdgeBasedRouteEngine

  DARK = 0
  DAYTIME = 1

  PROJECTION_SRID = 4326

  attr_reader :origin_lat, :origin_lng,
              :destination_lat, :destination_lng, :day_time

  def initialize(origin_lat, origin_lng, destination_lat, destination_lng, day_time)
    @origin_lat = origin_lat
    @origin_lng = origin_lng
    @destination_lat = destination_lat
    @destination_lng = destination_lng
    @day_time = day_time
  end

  def origin_edge
    @origin_edge ||= find_nearest_edge(@origin_lat, @origin_lng)
  end

  def destination_edge
    @destination_edge ||= find_nearest_edge(@destination_lat, @destination_lng)
  end

  def route
    return @lines if @lines
    if origin_edge && destination_edge
      pgr_result = Line.connection.execute(build_pgrouting_query)
      line_ids = pgr_result.map { |r| r['line_id'].to_i }
      @lines = Line.find_by_ordered_ids(line_ids)
      if @lines.length > 1
        cut_first_line
        cut_last_line
      elsif @lines.length == 1
        cut_one_line
      end
      @lines
    else
      nil
    end
  end

  protected

  BBOX_EXPANSION = 0.01

  def find_nearest_edge(lat, lng)
    Line.find_by_nearest(lat, lng, max: 1, inner_max: 20).take
  end

  def build_pgrouting_query
    %Q{
      SELECT seq, id1 vertex_id, id2 line_id, cost
      FROM pgr_trsp(
        'SELECT id, source::int, target::int, #{cost_column} AS cost FROM #{Line.table_name} WHERE geom_way && ST_Expand(ST_SetSRID(ST_MakeEnvelope(#{@origin_lng}, #{@origin_lat}, #{@destination_lng}, #{@destination_lat}), 4326), #{BBOX_EXPANSION})',
        #{origin_edge.id},
        (SELECT ST_LineLocatePoint(geom_way, #{build_point(@origin_lat, @origin_lng)}) FROM #{Line.table_name} WHERE id = #{origin_edge.id}),
        #{destination_edge.id},
        (SELECT ST_LineLocatePoint(geom_way, #{build_point(@destination_lat, @destination_lng)}) FROM #{Line.table_name} WHERE id = #{destination_edge.id}),
        false, false
      )
    }
  end

  def build_point(lat, lng)
    "ST_SetSRID(ST_MakePoint(#{lng}, #{lat}), #{PROJECTION_SRID})"
  end

  def cost_column
    @cost_column ||=
      case @day_time
      when DAYTIME then 'daytime_cost'
      when DARK then 'dark_cost'
      else
        raise 'Unknown day time for #{day_time}'
      end
  end

  def cut_first_line
    line_a = @lines[0]
    line_b = @lines[1]

    if line_a.geom_way.points.last == line_b.geom_way.points.first ||
       line_a.geom_way.points.last == line_b.geom_way.points.last
      start_fraction = "ST_LineLocatePoint(geom_way, #{build_point(@origin_lat, @origin_lng)})"
      end_fraction = '1'
    else
      start_fraction = '0'
      end_fraction = "ST_LineLocatePoint(geom_way, #{build_point(@origin_lat, @origin_lng)})"
    end

    line_column_names = Line.column_names.map do |name|
      if name == 'geom_way'
        "ST_LineSubstring(geom_way, #{start_fraction}, #{end_fraction}) AS geom_way"
      else
        name
      end
    end
    @lines[0] = Line.select(line_column_names).find(@lines.first.id)
  end

  def cut_last_line
    line_a = @lines[-1]
    line_b = @lines[-2]

    if line_a.geom_way.points.last == line_b.geom_way.points.last ||
       line_a.geom_way.points.last == line_b.geom_way.points.first
      start_fraction = "ST_LineLocatePoint(geom_way, #{build_point(@destination_lat, @destination_lng)})"
      end_fraction = '1'
    else
      start_fraction = '0'
      end_fraction = "ST_LineLocatePoint(geom_way, #{build_point(@destination_lat, @destination_lng)})"
    end

    line_column_names = Line.column_names.map do |name|
      if name == 'geom_way'
        "ST_LineSubstring(geom_way, #{start_fraction}, #{end_fraction}) AS geom_way"
      else
        name
      end
    end
    @lines[-1] = Line.select(line_column_names).find(@lines.last.id)
  end

  def cut_one_line
    start_fraction = "ST_LineLocatePoint(geom_way, #{build_point(@origin_lat, @origin_lng)})"
    end_fraction = "ST_LineLocatePoint(geom_way, #{build_point(@destination_lat, @destination_lng)})"
    line_column_names = Line.column_names.map do |name|
      if name == 'geom_way'
        "ST_LineSubstring(geom_way, #{start_fraction}, #{end_fraction}) AS geom_way"
      else
        name
      end
    end
    @lines[0] = Line.select(line_column_names).find(@lines.first.id)
  end
end
