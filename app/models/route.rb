class Route < ActiveRecord::Base
  
  scope :within_radius, -> from_latitude, from_longitude, to_latitude, to_longitude, radius, crime_day_time {
    where(
      "ST_DWithin(start_point, ST_SetSRID(ST_Point(:from_longitude, :from_latitude), 4326), :radius)
      and
      ST_DWithin(end_point, ST_SetSRID(ST_Point(:to_longitude, :to_latitude), 4326), :radius)
      and
      crime_day_time = :crime_day_time",
      {
        from_latitude: from_latitude,
        from_longitude: from_longitude,
        to_latitude: to_latitude,
        to_longitude: to_longitude,
        radius: radius,
        crime_day_time: crime_day_time
      }
    )
  }

end
