module Sphericalc

  class S2EdgeUtil

    # Find the distance to X along the great circle through AB.
    #
    # @param x [Sphericalc::S2Point]
    # @param a [Sphericalc::S2Point]
    # @param b [Sphericalc::S2Point]
    # @param a_cross_b [Sphericalc::S2Point] Precomputed cross product A and B.
    #   Cross product does not need to be normalized, but should be computed using
    #   Sphericalc::S2.robust_cross_prod(a, b) for the most accurate results.
    #
    # @return [Sphericalc::S1Angle]
    def self.get_perpendicular_distance(x, a, b, a_cross_b = Sphericalc::S2.robust_cross_prod(a, b))
      get_perpendicular_point(x, a, b, a_cross_b).angle(x)
    end

    # Find the closest point to X along the great circle through AB.
    #
    # @param x [Sphericalc::S2Point]
    # @param a [Sphericalc::S2Point]
    # @param b [Sphericalc::S2Point]
    # @param a_cross_b [Sphericalc::S2Point] Precomputed cross product A and B.
    #   Cross product does not need to be normalized, but should be computed using
    #   Sphericalc::S2.robust_cross_prod(a, b) for the most accurate results.
    #
    # @return [Sphericalc::S2Point]
    def self.get_perpendicular_point(x, a, b, a_cross_b = Sphericalc::S2.robust_cross_prod(a, b))
      x - (a_cross_b * (x.dot_prod(a_cross_b) / a_cross_b.norm2));
    end

  end
end
