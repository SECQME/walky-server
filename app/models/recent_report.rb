class RecentReport < ActiveRecord::Base
	belongs_to :user
	belongs_to :report_category

	scope :within_radius, -> latitude, longitude, radius {
		where(
			"ST_DWithin(location, ST_SetSRID(ST_Point(:longitude, :latitude), 4326), :radius) and invisible = false",
			{
				latitude: latitude,
				longitude: longitude,
				radius: radius
			}
		)
	}

	scope :within_bounds, -> sw_lat, sw_lng, ne_lat, ne_lng {
		where(
			"location && ST_MakeEnvelope(:sw_lng, :sw_lat, :ne_lng, :ne_lat, 4326) and invisible = false",
			{
				sw_lat: sw_lat,
				sw_lng: sw_lng,
				ne_lat: ne_lat,
				ne_lng: ne_lng
			}
		)
	}

  def readonly?
    true
  end

  def self.refresh
    ActiveRecord::Base.connection.execute("REFRESH MATERIALIZED VIEW CONCURRENTLY #{RecentReport.table_name};")
  end
end
