require 'spec_helper'

describe Sphericalc::S2Point do

  let(:point) { Sphericalc::S2Point.new(2, 1, -1) }
  let(:other_point) { Sphericalc::S2Point.new(-3, 4, 1) }

  context "cross product" do
    it "should return (5, 1, 11)" do
      cross_point = point.cross_prod(other_point)
      expect(cross_point).to eq(Sphericalc::S2Point.new(5, 1, 11))
    end
  end

  context "dot" do
    it "should return -3" do
      expect(point.dot_prod(other_point)).to eq(-3)
    end
  end

  context "norm" do
    it "should return sqrt(6)" do
      expect(point.norm).to eq(Math.sqrt(6))
    end
  end

  context "multiplication by scalar" do
    it "should return (12, 6, -6)" do
      expect(point * 6).to eq(Sphericalc::S2Point.new(12, 6, -6))
    end
  end
end
