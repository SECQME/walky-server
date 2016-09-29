require 'spec_helper'

describe Walky::AStar::PathFinder do
  let(:grid) do
    Walky::AStar::Grid.new 0, 0, 17, 17,
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 1, 1, 1, 4, 4, 4, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 1, 1, 1, 4, 4, 4, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 1, 1, 1, 4, 4, 4, 4, 4, 4, 2, 2, 2, 4, 4, 4, 4, 4, 4, 2, 2, 2, 4, 4, 4, 4, 4, 4, 2, 2, 2, 4, 4, 4, 4, 4, 4, 2, 2, 2, 4, 4, 4, 4, 4, 4, 2, 2, 2, 4, 4, 4, 4, 4, 4, 2, 2, 2, 4, 4, 4, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 4, 4, 4, 4, 4, 4, 2, 2, 2, 4, 4, 4, 4, 4, 4, 2, 2, 2, 4, 4, 4, 4, 4, 4, 2, 2, 2, 4, 4, 4, 4, 4, 4, 2, 2, 2, 4, 4, 4, 4, 4, 4, 2, 2, 2, 4, 4, 4, 4, 4, 4, 2, 2, 2, 1, 1, 1, 4, 4, 4, 2, 2, 2, 1, 1, 1, 4, 4, 4, 4, 4, 4, 1, 1, 1, 4, 4, 4, 2, 2, 2, 1, 1, 1, 4, 4, 4, 4, 4, 4, 1, 1, 1, 4, 4, 4, 2, 2, 2, 1, 1, 1, 4, 4, 4, 4, 4, 4, 2, 2, 2, 4, 4, 4, 1, 1, 1, 2, 2, 2, 2, 2, 2, 4, 4, 4, 2, 2, 2, 4, 4, 4, 1, 1, 1, 2, 2, 2, 2, 2, 2, 4, 4, 4, 2, 2, 2, 4, 4, 4, 1, 1, 1, 2, 2, 2, 2, 2, 2, 4, 4, 4]
  end

  let(:origin_row) { grid.min_row }
  let(:origin_col) { grid.min_col }
  let(:destination_row) { grid.max_row }
  let(:destination_col) { grid.max_col }
  let(:origin_tile) { grid.get_tile(origin_row, origin_col) }
  let(:destination_tile) { grid.get_tile(destination_row, destination_col) }

  let(:finder) { Walky::AStar::PathFinder.using_default_strategy.from(origin_tile).to(destination_tile) }
  let(:route) { finder.next_route }
  let(:path) { route.path }

  it "should start with origin" do
    tile = path.first
    expect(tile.row).to eq(origin_row)
    expect(tile.col).to eq(origin_col)
  end

  it "should finish in destination" do
    tile = path.last
    expect(tile.row).to eq(destination_row)
    expect(tile.col).to eq(destination_col)
  end

  it "should have 35 tiles length" do
    expect(path.length).to eq(35)
  end

  it "should have cost 57" do
    # path.each { |t| puts t }
    expect(route.cost).to eq(57)
  end
end
