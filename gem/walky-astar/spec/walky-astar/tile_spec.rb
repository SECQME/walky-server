require 'spec_helper'

describe Walky::AStar::Tile do

  let(:grid) do
    Walky::AStar::Grid.new 2, 3, 5, 5
  end

  shared_context "corner tile" do
    it 'should have 2 neighbours' do
      neighbours = grid.get_tile(row, col).walkable_neighbours
      expect(neighbours.length).to eq(2)
    end
  end

  context "upper-left tile" do
    let(:row) { grid.min_row }
    let(:col) { grid.min_col }

    include_context "corner tile"
  end

  context "upper-right tile" do
    let(:row) { grid.min_row }
    let(:col) { grid.max_col }

    include_context "corner tile"
  end

  context "lower-left tile" do
    let(:row) { grid.max_row }
    let(:col) { grid.min_col }

    include_context "corner tile"
  end

  context "lower-right tile" do
    let(:row) { grid.max_row }
    let(:col) { grid.max_col }

    include_context "corner tile"
  end

  context "center tile" do
    let(:row) { (grid.max_row + grid.min_row) >> 1 }
    let(:col) { (grid.max_col + grid.min_col) >> 1 }

    it 'should have 4 neighbours' do
      neighbours = grid.get_tile(row, col).walkable_neighbours
      expect(neighbours.length).to eq(4)
    end
  end
end
