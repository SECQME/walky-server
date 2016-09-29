module Sphericalc

  class S2

    EARTH_RADIUS = 6378137.0

    # Return a unit-length vector that is orthogonal to "a".  Satisfies
    # Ortho(-a) = -Ortho(a) for all a.
    def self.ortho(a)
      # # Sphericalc::S2Point#ortho always returns a point on the X-Y, Y-Z, or X-Z planes.
      # # This leads to many more degenerate cases in polygon operations.
      # return a.ortho

      int k = a.largest_abs_component - 1;
      k = 2 if (k < 0)
      temp = Sphericalc::S2Point.new(0.012, 0.0053, 0.00457)
      temp[k] = 1;
      return a.cross_prod(temp).normalize
    end

    # Return a vector "c" that is orthogonal to the given unit-length vectors
    # "a" and "b".  This function is similar to a.CrossProd(b) except that it
    # does a better job of ensuring orthogonality when "a" is nearly parallel
    # to "b", and it returns a non-zero result even when a == b or a == -b.
    #
    # It satisfies the following properties (RCP == RobustCrossProd):
    #
    #   (1) RCP(a,b) != 0 for all a, b
    #   (2) RCP(b,a) == -RCP(a,b) unless a == b or a == -b
    #   (3) RCP(-a,b) == -RCP(a,b) unless a == b or a == -b
    #   (4) RCP(a,-b) == -RCP(a,b) unless a == b or a == -b
    #
    # @param a [Sphericalc::S2Point]
    # @param b [Sphericalc::S2Point]
    #
    # @return [Sphericalc::S2Point]
    def self.robust_cross_prod(a, b)
      # The direction of a.CrossProd(b) becomes unstable as (a + b) or (a - b)
      # approaches zero.  This leads to situations where a.CrossProd(b) is not
      # very orthogonal to "a" and/or "b".  We could fix this using Gram-Schmidt,
      # but we also want b.RobustCrossProd(a) == -a.RobustCrossProd(b).
      #
      # The easiest fix is to just compute the cross product of (b+a) and (b-a).
      # Mathematically, this cross product is exactly twice the cross product of
      # "a" and "b", but it has the numerical advantage that (b+a) and (b-a)
      # are always perpendicular (since "a" and "b" are unit length).  This
      # yields a result that is nearly orthogonal to both "a" and "b" even if
      # these two values differ only in the lowest bit of one component.

      x = (b + a).cross_prod(b - a)
      return x unless x == Sphericalc::S2Point.new(0, 0, 0)

      # The only result that makes sense mathematically is to return zero, but
      # we find it more convenient to return an arbitrary orthogonal vector.
      return self.ortho(a);
    end
  end

end
