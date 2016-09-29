module Walky::AStar
  class Node
    attr_reader :tile, :parent, :destination, :f, :g, :h

    def initialize(tile, destination, strategy, parent=nil)
      @tile = tile
      @parent = parent
      @destination = destination

      @strategy = strategy.new(self)

      @g = @strategy.g
      @h = destination ? @strategy.h : 0
      @f = @g + @h
    end

    def walkable_neighbours
      @tile.walkable_neighbours
    end

    def x
      @tile.x
    end

    def y
      @tile.y
    end

    def == (other)
      self.x == other.x and self.y == other.y
    end

    def is_destination?
      self.x == destination.x and self.y == destination.y
    end

    def to_s
      "[#{@tile}; #{f} = #{g} + #{h}]"
    end
  end
end
