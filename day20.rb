# Part 1
puts "Part 1"

require 'set'
class Map
  attr_accessor :tokens, :grid

  ROOM = '.'.freeze
  WALL = '#'.freeze
  HORIZONTAL_DOOR = '-'.freeze
  VERTICAL_DOOR = '|'.freeze
  DOORS = [HORIZONTAL_DOOR, VERTICAL_DOOR]
  LENGTH = 1000

  def initialize(input)
    @tokens = input.chars[1..-2]
    @grid = Array.new(LENGTH) { Array.new(LENGTH, WALL) }
    @i = @grid.length / 2
    @j = @grid[0].length / 2
    @origin = [@i, @j]
    @window = [@i, @i, @j, @j]
    @prev_branches = []
    @grid[@i][@j] = 'X'
  end

  def process_tokens!
    loop do
      token = @tokens.shift
      return if token.nil?

      case token
      when 'N'
        @i -= 1
        @grid[@i][@j] = HORIZONTAL_DOOR
        @i -= 1
        @grid[@i][@j] = ROOM
      when 'E'
        @j += 1
        @grid[@i][@j] = VERTICAL_DOOR
        @j += 1
        @grid[@i][@j] = ROOM
      when 'S'
        @i += 1
        @grid[@i][@j] = HORIZONTAL_DOOR
        @i += 1
        @grid[@i][@j] = ROOM
      when 'W'
        @j -= 1
        @grid[@i][@j] = VERTICAL_DOOR
        @j -= 1
        @grid[@i][@j] = ROOM
      when '('
        @prev_branches << [@i, @j]
      when '|'
        @i, @j = @prev_branches.last
      when ')'
        @prev_branches.pop
      else raise "wtf #{token}"
      end

      min_i, max_i, min_j, max_j = @window
      min_i, max_i = [@i, min_i, max_i].minmax
      min_j, max_j = [@j, min_j, max_j].minmax
      @window = [min_i, max_i, min_j, max_j]
    end
  end

  def to_s
    min_i, max_i, min_j, max_j = @window
    @grid[(min_i - 1)..(max_i + 1)].map { |row| row[(min_j - 1)..(max_j + 1)].join }
  end

  def find_farthest_room
    seen = Set.new
    queue = [[*@origin, 0]]
    max_dist = 0
    at_least_1000 = 0

    until queue.empty?
      i, j, dist = queue.shift
      max_dist = [max_dist, dist].max
      seen << [i, j]
      neighbors(i, j).each do |i2, j2|
        next if seen.include?([i2, j2])
        at_least_1000 += 1 if dist + 1 >= 1000
        queue << [i2, j2, dist + 1]
        seen << [i2, j2]
      end
    end

    [max_dist, at_least_1000]
  end

  def neighbors(i, j)
    neighbors = []
    neighbors << [i + 2, j] if @grid[i + 1][j] == HORIZONTAL_DOOR

    neighbors << [i - 2, j] if @grid[i - 1][j] == HORIZONTAL_DOOR

    neighbors << [i, j + 2] if @grid[i][j + 1] == VERTICAL_DOOR

    neighbors << [i, j - 2] if @grid[i][j - 1] == VERTICAL_DOOR
    neighbors
  end
end


map = Map.new(File.read('input20.txt').chomp)
map.process_tokens!
max_dist, at_least_1000 = map.find_farthest_room

puts max_dist

# Part 2
puts "Part 2"
puts at_least_1000
