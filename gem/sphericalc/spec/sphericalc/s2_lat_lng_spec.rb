require 'spec_helper'

describe Sphericalc::S2LatLng do

  let(:latlng) { Sphericalc::S2LatLng.from_degrees(41.89709301389319, -87.67368230851747) }
  let(:other_latlng) { Sphericalc::S2LatLng.from_degrees(41.872555432605196,-87.64089498551942) }

  context "to_point" do
    it "should return (0.030213538178651383, -0.743731980894342, 0.6677947908644581)" do
      expect(latlng.to_point).to eq(Sphericalc::S2Point.new(0.030213538178651383, -0.743731980894342, 0.6677947908644581))
    end
  end

  context "distance" do
    it "should have 3.8 km distance" do
      distance = latlng.distance_to(other_latlng)
      puts distance
      puts distance.radians * Sphericalc::S2::EARTH_RADIUS
    end
  end
end
