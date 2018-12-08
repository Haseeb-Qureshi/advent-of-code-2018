# Specifically, a node consists of:

# A header, which is always exactly two numbers:
# The quantity of child nodes.
# The quantity of metadata entries.
# Zero or more child nodes (as specified in the header).
# One or more metadata entries (as specified in the header).

# Part 1
puts "Part 1"

INPUT = File.read('input08.txt').chomp!.split.map(&:to_i)

class Node
  attr_reader :children
  attr_reader :metadata
  def initialize(children = [], metadata = [])
    @children = children
    @metadata = metadata
  end

  def self.create_node(input)
    create_node!(input.dup)
  end

  def self.create_node!(input)
    node = Node.new
    num_child_nodes = input.shift
    num_metadata = input.shift
    num_child_nodes.times { node.children << create_node!(input) }
    num_metadata.times { node.metadata << input.shift }

    node
  end

  def all_metadata
    [@metadata, @children.map(&:all_metadata)].flatten
  end

  def metadata_sum
    all_metadata.reduce(:+)
  end

  def value
    return @metadata.reduce(:+) if @children.empty?

    @metadata.map do |num|
      idx = num - 1
      idx.between?(0, @children.length - 1) ? @children[idx].value : 0 
    end.reduce(:+)
  end
end

root = Node.create_node(INPUT)
puts root.metadata_sum

# Part 2
puts "Part 2"
puts root.value
