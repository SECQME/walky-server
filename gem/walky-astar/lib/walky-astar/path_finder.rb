require "walky-astar/heuristic"
require "walky-astar/heuristic/euclidean_distance"
require "walky-astar/heuristic/manhatten_distance"
require "walky-astar/node"
require "walky-astar/version"
require "walky-astar/route"

module Walky::AStar
  class PathFinder
    attr_accessor :strategy

    def self.using_default_strategy
      self.using_manhatten_distance_strategy
    end

    def self.using_manhatten_distance_strategy
      new(ManhattenDistance)
    end

    def self.using_euclidean_distance_strategy
      new(EuclideanDistance)
    end

    def from(node)
      @from_node = Node.new(node, nil, @strategy)
      self
    end

    def to(node)
      @to_node = Node.new(node, nil, @strategy)
      @open_list << Node.new(@from_node.tile, @to_node, @strategy)
      self
    end

    def next_route
      until @open_list.empty?
        current_node = @open_list.shift
        return Route.new current_node if current_node.is_destination?
        # puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> #{current_node}"
        add_neighbours_to_open_list(current_node, current_node.walkable_neighbours)
        calculate_fastest
        @closed_list << current_node
      end
      nil
    end

    def add_neighbours_to_open_list(current_node, neighbours)
      neighbours.each do |n|
        new_node = Node.new(n, @to_node, @strategy, current_node)

        # puts "Neighbours: #{new_node}"

        same_node = @closed_list.find { |existing_node| existing_node == new_node }
        # puts "Closed node: #{same_node}"
        next if same_node and same_node.f <= new_node.f

        same_node = @open_list.find { |existing_node| existing_node == new_node }
        # puts "Opened node: #{same_node}"
        next if same_node and same_node.f <= new_node.f

        # puts "Inserted as opened node"
        @open_list << new_node
      end
    end

    def calculate_fastest
      @open_list.sort_by! {|node| node.f }
      # puts @open_list
    end

    def destination_reached?
      @closed_list.any? { |node| node.x == @to_node.x && node.y == @to_node.y }
    end

    private
    def initialize(strategy)
      @strategy = strategy
      @open_list = []
      @closed_list = []
    end
  end
end
