module Sphericalc

  class Line

    attr_accessor :start, :finish

    def initialize(start, finish)
      @start = start
      @finish = finish
    end

    def to_s
      "[#{@start}, #{@finish}]"
    end

    def ==(other)
      (@x == other.x) and (@y == other.y) and (@z == other.z)
    end
  end
end
