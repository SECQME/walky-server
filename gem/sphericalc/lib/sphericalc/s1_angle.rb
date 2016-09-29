module Sphericalc

  class S1Angle

    def self.from_radians(radians)
      Sphericalc::S1Angle.new(radians)
    end

    def self.from_degrees(degrees)
      Sphericalc::S1Angle.new(degrees * (Math::PI / 180))
    end

    # Return the angle between two points, which is also equal to the distance
    # between these points on the unit sphere.  The points do not need to be
    # normalized.
    #
    # @param origin [Sphericalc::S2Point] Original point
    # @param destination [Sphericalc::S2Point] Destination point
    def self.from_points(origin, destination)
      origin.angle(destination)
    end

    def self.from_latlngs(origin, destination)
      origin.distance_to(destination)
    end

    def self.from_actual_distance(distance, sphere_radius = Sphericalc::S2::EARTH_RADIUS)
      Sphericalc::S1Angle.new(distance / sphere_radius)
    end

    def radians
      @radians
    end

    def degrees
      @radians * (180 / Math::PI)
    end

    def normalize!
      @radians = @radians % (2.0 * Math.PI)
      @radians = Math.PI if (@radians <= -Math.PI)
      self
    end

    def normalize
      Sphericalc::S1Angle.new(@radians).normalize!
    end

    def to_actual_distance(sphere_radius = Sphericalc::S2::EARTH_RADIUS)
      @radians * sphere_radius
    end

    def to_s
      "#{degrees}"
    end

    def ==(other)
      @radians == other.radians
    end

    def <(other)
      @radians < other.radians
    end

    def >(other)
      @radians > other.radians
    end

    def <=(other)
      @radians <= other.radians
    end

    def >=(other)
      @radians >= other.radians
    end
    
    private
      def initialize(radians)
        @radians = radians
      end
  end
end
