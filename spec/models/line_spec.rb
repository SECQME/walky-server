require 'spec_helper'

describe Line do

  let(:line) { Line.first }

  it { is_expected.to respond_to(:id) }
  it { is_expected.to respond_to(:source) }
  it { is_expected.to respond_to(:target) }
  it { is_expected.to respond_to(:osm_id) }
  it { is_expected.to respond_to(:osm_name) }
  it { is_expected.to respond_to(:geom_way) }
  it { is_expected.to respond_to(:dark_cost) }
  it { is_expected.to respond_to(:daytime_cost) }

  describe '::find_by_nearest' do
    it 'takes nearest lines' do
      expect(
        Line.find_by_nearest(
          line.geom_way.points.first.y,
          line.geom_way.points.first.x
        )
      ).to include(line)
    end
  end

  describe '::find_by_ordered_ids' do
    it 'sorts line by specified ids' do
      line_ids = Line.take(5).map { |line| line.id }.shuffle
      expect(
        Line.find_by_ordered_ids(line_ids).map { |line| line.id }
      ).to eq(line_ids)
    end
  end
end
