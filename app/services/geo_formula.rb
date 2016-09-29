class GeoFormula
  class << self
		EARTH_RADIUS = 6371.0

		def to_rad angle
			radian = (angle * Math::PI) / 180.0
			radian
		end

		def to_deg rad
			degree = (rad * 180.0) / Math::PI
			degree
		end

    def normalize_rad(rad)
      (rad + (2 * Math::PI)) % Math::PI
    end

    def normalize_deg(deg)
      (deg + 360.0) % 360.0
    end

		def distance lat1, lng1, lat2, lng2
			return 0.0 if (lat1 - lat2).abs < 0.000001 and (lng1 - lng2).abs < 0.000001
			# Math.acos(Math.sin(theta1) * Math.sin(theta2) + Math.cos(theta1) * Math.cos(theta2) * Math.cos(avgLamda)) * EARTH_RADIUS
			theta1 = to_rad(lat1.to_f)
			theta2 = to_rad(lat2.to_f)
			avg_lamda = to_rad(lng2.to_f - lng1.to_f)
			distance = Math.acos(Math.sin(theta1) * Math.sin(theta2) + Math.cos(theta1) * Math.cos(theta2) * Math.cos(avg_lamda)) * EARTH_RADIUS
			distance
		end

		def bearing lat1, lng1, lat2, lng2
      # Formula from
			# http://gis.stackexchange.com/questions/29239/calculate-bearing-between-two-decimal-gps-coordinates
			beta_1, lamda_1 = to_rad(lat1), to_rad(lng1)
			beta_2, lamda_2 = to_rad(lat2), to_rad(lng2)
			dLong = lamda_2 - lamda_1
			dPhi = Math.log(Math.tan(beta_2/2.0 + Math::PI/4.0)/ Math.tan(beta_1/2.0 + Math::PI/4.0))

      if dLong.abs > Math::PI
        if dLong > 0.0
          dLong = -(2.0 * Math::PI - dLong)
        else
          dLong = (2.0 * Math::PI + dLong)
        end
      end

      normalize_deg(to_deg(Math.atan2(dLong, dPhi)))
		end

		def final_bearing start_degree
			(start_degree + 180) % 360
		end

		def to_row matrix_length , lat1, lng1, lat2, lng2, grid_distance
			# (matrixLength - 1) - ((int) Math.floor((this.distanceBetweenTwoLocation(lat1,lng1,lat2,lng2))/ crimeCellDistanceInKM));
			row_index = (matrix_length - 1) - (distance(lat1,lng1,lat2,lng2))/grid_distance.to_f
			row_index.to_i
		end

		def to_col lat1, lng1, lat2, lng2, grid_distance
			col_index = (distance(lat1,lng1,lat2,lng2))/grid_distance.to_f
			col_index.to_i
		end

		def to_row_col city, lat, lng
			[
				to_row(city.total_rows, city.south_west.y, lng, lat, lng, city.grid_size),
				to_col(lat, city.south_west.x, lat, lng, city.grid_size)
			]
		end

		def project_point lat, lng, bearing, distance
			dist = distance.to_f / EARTH_RADIUS
			brng = to_rad(bearing)
			lat_rad = to_rad(lat)
			lng_rad = to_rad(lng)

			latitude = Math.asin( Math.sin(lat_rad) * Math.cos(dist) + Math.cos(lat_rad) * Math.sin(dist) * Math.cos(brng) )
			a = Math.atan2( Math.sin(brng) * Math.sin(dist) * Math.cos(lat_rad), Math.cos(dist) - Math.sin(lat_rad) * Math.sin(latitude))
			longitude = ((lng_rad + a) + 3 * Math::PI) % (2*Math::PI) - Math::PI

      {
        lat: to_deg(latitude),
        lng: to_deg(longitude)
      }
		end
	end

  def method_missing name, *args, &block
    if self.class.respond_to? name
      self.class.send name, *args, &block
    else
      super
    end
  end
end
