class City < ActiveRecord::Base

	scope :contains, -> latitude, longitude {
    where(
      "ST_CoveredBy(ST_SetSRID(ST_MakePoint(:longitude, :latitude), 4326), area)",
      {
				latitude: latitude,
				longitude: longitude,
      }
    )
  }

  scope :intersect_with_bounds, -> sw_lat, sw_lng, ne_lat, ne_lng {
    where(
			"area && ST_MakeEnvelope(:sw_lng, :sw_lat, :ne_lng, :ne_lat, 4326)",
			{
				sw_lat: sw_lat,
				sw_lng: sw_lng,
				ne_lat: ne_lat,
				ne_lng: ne_lng
			}
		)
	}

	def as_json(options={})
		options[:except] ||= [:area]
		super(options)
	end
end
