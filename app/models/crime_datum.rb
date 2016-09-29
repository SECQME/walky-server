class CrimeDatum < ActiveRecord::Base
	self.table_name = "crime_data"

	belongs_to :crime_type
	belongs_to :city

	scope :within_radius, -> latitude, longitude, radius {
		where(
			"ST_DWithin(location, ST_SetSRID(ST_Point(:longitude, :latitude), 4326), :radius)",
			{
				latitude: latitude,
				longitude: longitude,
				radius: radius
			}
		)
	}

	scope :within_bounds, -> sw_lat, sw_lng, ne_lat, ne_lng {
		where(
			"location && ST_MakeEnvelope(:sw_lng, :sw_lat, :ne_lng, :ne_lat, 4326)",
			{
				sw_lat: sw_lat,
				sw_lng: sw_lng,
				ne_lat: ne_lat,
				ne_lng: ne_lng
			}
		)
	}
end
