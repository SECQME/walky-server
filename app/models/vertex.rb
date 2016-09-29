class Vertex < ActiveRecord::Base
  self.table_name = "mykl_2po_vertex"

  scope :order_by_nearest, -> latitude, longitude {
    order("geom_vertex <-> ST_SetSRID(ST_Point(#{longitude.to_f}, #{latitude.to_f}), 4326)")
  }
end
