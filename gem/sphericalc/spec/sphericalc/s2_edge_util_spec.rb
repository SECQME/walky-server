require 'spec_helper'

describe Sphericalc::S2EdgeUtil do

  context "calculate perpendicular distance" do
    let(:a) { Sphericalc::S2LatLng.from_degrees(41.89709301389319, -87.67368230851747).to_point }
    let(:b) { Sphericalc::S2LatLng.from_degrees(41.872555432605196, -87.64089498551942).to_point }
    # let(:x) { Sphericalc::S2LatLng.from_degrees(41.890281, -87.654710).to_point }
    let(:x) { Sphericalc::S2LatLng.from_degrees(41.86304, -87.64223).to_point }

    it "should ..." do
      robust_cross_point = Sphericalc::S2.robust_cross_prod(a, b)
      perpendicular_point = Sphericalc::S2EdgeUtil.get_perpendicular_point(x, a, b, robust_cross_point)
      puts Sphericalc::S2LatLng.from_point robust_cross_point
      puts Sphericalc::S2LatLng.from_point perpendicular_point
      puts perpendicular_point.angle(x).to_actual_distance

      # result: a-b-x-p: y_v~FnwbvOhxC}kEwmBjuA|U~]
      # y_v~FnwbvOhxC}kEwmBjuA|U~]hrC_lBu_@ck@yYvb@
    end
  end
end
