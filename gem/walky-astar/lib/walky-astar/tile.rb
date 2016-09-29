module Walky::AStar
  class Tile
    attr_reader :row, :col, :score
    attr_reader :y, :x

    def initialize(row, col, score, grid)
      @x = @col = col
      @y = @row = row
      @score = score
      @grid = grid
    end

    def walkable_neighbours
      @grid.neighbours_of self
    end

    def to_s
      "#{@row}, #{@col}: #{@score}"
    end
  end
end
