module Sphericalc

  class S2LatLng
    
    attr_accessor :lat, :lng

    def self.from_degrees(lat, lng)
      Sphericalc::S2LatLng.new(
        Sphericalc::S1Angle.from_degrees(lat),
        Sphericalc::S1Angle.from_degrees(lng)
      )
    end

    def self.from_point(p)
      Sphericalc::S2LatLng.new(
        Sphericalc::S1Angle.from_radians(Math.atan2(p.z, Math.sqrt(p.x*p.x + p.y*p.y))),
        Sphericalc::S1Angle.from_radians(Math.atan2(p.y, p.x))
      )
    end

    # Return the distance (measured along the surface of the sphere) to the
    # given S2LatLng.  This is mathematically equivalent to:
    #
    #   Sphericalc::S1Angle.from_radians(self.to_point.angle(other.to_point))
    #
    # but this implementation is slightly more efficient. Both S2LatLngs
    # must be normalized.
    #
    # @return [Sphericalc::S1Angle]
    #
    def distance_to(other)
      lat1 = @lat.radians;
      lat2 = other.lat.radians;
      lng1 = @lng.radians;
      lng2 = other.lng.radians;
      dlat = Math.sin(0.5 * (lat2 - lat1));
      dlng = Math.sin(0.5 * (lng2 - lng1));
      x = dlat * dlat + dlng * dlng * Math.cos(lat1) * Math.cos(lat2);
      return Sphericalc::S1Angle.from_radians(2 * Math.atan2(Math.sqrt(x), Math.sqrt([0.0, 1.0 - x].max)));
    end

    def to_point
      Sphericalc::S2Point.new(
        Math.cos(@lng.radians) * Math.cos(@lat.radians),
        Math.sin(@lng.radians) * Math.cos(@lat.radians),
        Math.sin(@lat.radians)
      )
    end

    def to_s
      "(#{@lat}, #{@lng})"
    end

    def ==(other)
      (@lat == other.lat) and (@lng == other.lng)
    end

    private
      def initialize(lat, lng)
        @lat = lat
        @lng = lng
      end
  end
end
