
class CoordinateCalculator
	EARTH_RADIUS = 6371.0

	class << self
		def to_radians angle
			angle / 180 * Math::PI
		end

		def to_degree angle
			angle / Math::PI * 180
		end

		def distance(lat1, lng1, lat2, lng2)
			theta_1 = self.to_radians(lat1)
			theta_2 = self.to_radians(lat2)
			avg_lambda = self.to_radians(lng2 - lng1)

			Math.acos(Math.sin(theta_1) * Math.sin(theta_2) +
				Math.cos(theta_1) * Math.cos(theta_2) * Math.cos(avg_lambda)) * EARTH_RADIUS
		end

		def bearing(lat1, lng1, lat2, lng2)
			# Formula from
			# http://gis.stackexchange.com/questions/29239/calculate-bearing-between-two-decimal-gps-coordinates
			beta_1, lamda_1 = self.to_radians(lat1), self.to_radians(lng1)
			beta_2, lamda_2 = self.to_radians(lat2), self.to_radians(lng2)
			dLong = lamda_2 - lamda_1
			dPhi = Math.log(Math.tan(beta_2/2.0 + Math::PI/4.0)/ Math.tan(beta_1/2.0 + Math::PI/4.0))
			if dLong.abs > Math::PI
				if dLong > 0.0
					dLong = -(2.0 * Math::PI - dLong)
				else
					dLong = (2.0 * Math::PI + dLong)
				end
			end
			delta = (self.to_degree(Math.atan2(dLong,dPhi))+360.0) % 360.0
			delta
		end

		def final_bearing start_degree
			(start_degree + 180) % 360
		end

		def new_coordinate(lat, lng, bearing, distance)
			dist = distance.to_f / EARTH_RADIUS
			delta = self.to_radians(bearing)
			beta_1, lamda_1 = self.to_radians(lat), self.to_radians(lng)

			lat2 = Math.asin( Math.sin(beta_1)*Math.cos(dist) + Math.cos(beta_1)*Math.sin(dist)*Math.cos(delta) )
			a = Math.atan2(Math.sin(delta)*Math.sin(dist)*Math.cos(beta_1), Math.cos(dist)-Math.sin(beta_1)*Math.sin(lat2))
			lon2 = lamda_1 + a
			lon2 = (lon2+ 3*Math::PI) % (2*Math::PI) - Math::PI
			return {:latitude => self.to_degree(lat2),:longitude => self.to_degree(lon2)}
		end
	end
end
