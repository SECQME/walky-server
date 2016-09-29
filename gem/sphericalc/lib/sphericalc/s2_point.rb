module Sphericalc

  class S2Point

    def initialize(x, y, z)
      @c = [x, y, z]
    end

    def x
      @c[0]
    end

    def y
      @c[1]
    end

    def z
      @c[2]
    end

    # Take the abs of each component and return a vector containing those values
    def abs
      Sphericalc::S2Point.new(
        @c[0].abs,
        @c[1].abs,
        @c[2].abs
      )
    end

    def angle(other)
      Sphericalc::S1Angle.from_radians(Math.atan2(self.cross_prod(other).norm, self.dot_prod(other)))
    end

    def cross_prod(other)
      Sphericalc::S2Point.new(
        @c[1] * other.z - @c[2] * other.y,
        @c[2] * other.x - @c[0] * other.z,
        @c[0] * other.y - @c[1] * other.x
      )
    end

    def dot_prod(other)
      (@c[0] * other.x) + (@c[1] * other.y)  + (@c[2] * other.z)
    end

    # Return the index of the largest component (abs)
    def largest_abs_component
      abs_point = self.abs
      temp = [abs_point.x, abs_point.y, abs_point.z]
      if (temp[0] > temp[1])
        if (temp[0] > temp[2])
          return 0
        else
          return 2
        end
      else
        if (temp[1] > temp[2])
          return 1
        else
          return 2
        end
      end
    end

    # Return the squared Euclidean norm of the vector.  Be aware that if VType
    # is an integer type, the high bits of the result are silently discarded.
    def norm2
      (@c[0] * @c[0]) + (@c[1] * @c[1]) + (@c[2] * @c[2])
    end

    # Return the Euclidean norm of the vector.  Note that if VType is an
    # integer type, the return value is correct only if the *squared* norm does
    # not overflow VType.
    def norm
      Math.sqrt(norm2)
    end

    # Return a normalized version of the vector if the norm of the
    # vector is not 0.
    def normalize
      n = self.norm
      n = (1.0 / n) if (n > 0)
      Sphericalc::S2Point.new(@c[0], @c[1], @c[2]) * n
    end

    def to_s
      "(#{@c[0]}, #{@c[1]}, #{@c[2]})"
    end

    def ==(other)
      (@c[0] == other.x) and (@c[1] == other.y) and (@c[2] == other.z)
    end

    def *(scalar)
      Sphericalc::S2Point.new(
        @c[0] * scalar,
        @c[1] * scalar,
        @c[2] * scalar
      )
    end

    def /(scalar)
      Sphericalc::S2Point.new(
        @c[0] / scalar,
        @c[1] / scalar,
        @c[2] / scalar
      )
    end

    def +(other)
      Sphericalc::S2Point.new(
        @c[0] + other.x,
        @c[1] + other.y,
        @c[2] + other.z
      )
    end

    def -(other)
      Sphericalc::S2Point.new(
        @c[0] - other.x,
        @c[1] - other.y,
        @c[2] - other.z
      )
    end
  end
end
