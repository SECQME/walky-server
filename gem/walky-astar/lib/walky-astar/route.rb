module Walky::AStar
  class Route
    def initialize(node)
      @node = node
    end

    def raw
      @node
    end

    def path
      node = @node
      path = [node.tile]
      while node.parent
        node = node.parent
        path << node.tile
      end
      path.reverse
    end

    def cost
      @node.f
    end
  end
end
