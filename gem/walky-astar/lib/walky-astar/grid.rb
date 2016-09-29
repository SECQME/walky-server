require "walky-astar/tile"

module Walky::AStar
  class Grid

    attr_reader :min_row, :min_col, :max_row, :max_col

    attr_accessor :diagonal_neighbours

    def initialize(min_row, min_col, max_row, max_col, tile_scores = nil)
      @min_row = min_row
      @min_col = min_col
      @max_row = max_row
      @max_col = max_col

      @tiles = Array.new(max_row-min_row+1) { Array.new(max_col-min_col+1) }

      pos = 0
      for i in min_row..max_row
        for j in min_col..max_col
          score = tile_scores ? tile_scores[pos] : 1
          tile = Tile.new(i, j, score, self)
          set_tile(i, j, tile)
          pos += 1
        end
      end
    end

    def neighbours_of(tile)
      min_row = tile.row > @min_row ? tile.row - 1 : tile.row
      min_col = tile.col > @min_col ? tile.col - 1 : tile.col
      max_row = tile.row < @max_row ? tile.row + 1 : tile.row
      max_col = tile.col < @max_col ? tile.col + 1 : tile.col

      neighbours = []
      for i in min_row..max_row
        for j in min_col..max_col
          if diagonal_neighbours
            neighbours << get_tile(i, j) unless (i == tile.row and j == tile.col)
          else
            neighbours << get_tile(i, j) if ((i == tile.row or j == tile.col) and not (i == tile.row and j == tile.col))
          end
        end
      end

      neighbours
    end

    def get_tile(row, col)
      @tiles[row - @min_row][col - @min_col]
    end

    def set_tile(row, col, tile)
      @tiles[row - @min_row][col - @min_col] = tile
    end
  end
end
