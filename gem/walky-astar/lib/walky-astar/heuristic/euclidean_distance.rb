module Walky::AStar
  class EuclideanDistance < Heuristic
    def g
      return @node.g if @node.g

      g = @node.tile.score
      if (@node.parent)
        g = @node.parent.g + @node.tile.score
      end
      return g
    end

    def h
      delta_x = @node.destination.x - @node.x
      delta_y = @node.destination.y - @node.y
      Math.sqrt((delta_x * delta_x) + (delta_y * delta_y))
    end
  end
end
