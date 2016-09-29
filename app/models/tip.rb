class Tip < ActiveRecord::Base
  validates :description, :location, :username, :user_id, presence: true
  validates :description, length: { maximum: 255 }

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
