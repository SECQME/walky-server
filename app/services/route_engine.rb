class RouteEngine

  DARK = 0
  DAYTIME = 1

  def find_route(origin_vertex, destination_vertex, day_time)
    pgr_query = %Q{
      SELECT seq, id1 vertex_id, id2 line_id, cost
      FROM pgr_dijkstra(
        'SELECT id, source::int, target::int, #{cost_column(day_time)} AS cost FROM #{Line.table_name} WHERE geom_way && ST_Expand(ST_SetSRID(ST_MakeEnvelope(#{origin_vertex.geom_vertex.x}, #{origin_vertex.geom_vertex.y}, #{destination_vertex.geom_vertex.x}, #{destination_vertex.geom_vertex.y}), 4326), #{BBOX_EXPANSION})',
        #{origin_vertex.id}, #{destination_vertex.id}, false, false
      )
    }

    pgr_result = Line.connection.execute(pgr_query)

    line_ids = pgr_result.map { |r| r["line_id"].to_i }
    line_ids.pop # Remove last dummy line (-1), http://docs.pgrouting.org/2.0/en/src/dijkstra/doc/index.html#pgr-dijkstra
    Line.find_by_ordered_ids(line_ids)
  end

  protected

  BBOX_EXPANSION = 0.02

  def cost_column(day_time)
    case day_time
    when DAYTIME
      return "daytime_cost"
    when DARK
      return "dark_cost"
    else
      raise "Unknown day time for #{day_time}"
    end
  end

end
