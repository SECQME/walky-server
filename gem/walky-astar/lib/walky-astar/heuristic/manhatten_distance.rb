module Walky::AStar
  class ManhattenDistance < Heuristic
    def g
      return @node.g if @node.g

      g = @node.tile.score
      if (@node.parent)
        g = @node.parent.g + @node.tile.score
      end
      return g
    end

    def h
      (@node.destination.x - @node.x).abs + (@node.destination.y - @node.y).abs
    end
  end
end
