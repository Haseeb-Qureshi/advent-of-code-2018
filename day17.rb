require 'set'
require 'pry'

# Part 1
puts "Part 1"

class Reservoir
  EMPTY = '.'.freeze
  WATER_SOURCE = '+'.freeze
  BOUNDARY = '#'.freeze
  SETTLED = '~'.freeze
  DOWNTRICKLE = '|'.freeze
  BUILDABLE = [BOUNDARY, SETTLED].freeze

  def initialize(input)
    @max_x = 0
    @max_y = 0
    @min_x = Float::INFINITY
    @min_y = Float::INFINITY
    boundaries = input.lines.map do |line|
      value_y = parse_value(line[/y=([^\s,]+)/][2..-1])
      value_x = parse_value(line[/x=([^\s,]+)/][2..-1])
      @max_x = [@max_x, size(value_x, type: :max)].max
      @max_y = [@max_y, size(value_y, type: :max)].max
      @min_x = [@min_x, size(value_x, type: :min)].min
      @min_y = [@min_y, size(value_y, type: :min)].min
      { x: value_x, y: value_y }
    end

    @min_x -= 1
    @max_x += 1

    @grid = Array.new(@max_y + 1) { Array.new(@max_x + 1, nil) }
    (0..@max_y).each do |i|
      (@min_x..@max_x).each do |j|
        self[i, j] = EMPTY
      end
    end
    self[0, 500] = WATER_SOURCE
    @trickled_from = Set.new

    # place down clay boundaries
    boundaries.each do |boundary|
      x = boundary[:x]
      y = boundary[:y]

      if x.is_a?(Range)
        x.each { |j| self[y, j] = BOUNDARY }
      else
        y.each { |i| self[i, x] = BOUNDARY }
      end
    end
  end

  def parse_value(s)
    if s.include?('..')
      Range.new(*s.scan(/\d+/).map(&:to_i))
    else
      s.to_i
    end
  end

  def size(el, type:)
    return el unless el.is_a?(Range)
    if type == :max
      el.end
    elsif type == :min
      el.begin
    end
  end

  def print_grid
    @grid.each do |row|
      puts row.reject(&:nil?).join
    end
    nil
  end

  def in_range?(i, j)
    i >= @min_y && j >= 0 && i <= @max_y && j < @grid[0].length && !self[i, j].nil?
  end

  def in_starting_range?(i, j)
    i >= 0 && j >= 0 && i <= @max_y && j < @grid[0].length
  end

  def first_trickle(i, j)
    loop do
      i += 1
      return unless in_starting_range?(i, j)
      if self[i, j] == EMPTY
        self[i, j] = DOWNTRICKLE
      elsif BUILDABLE.include?(self[i, j])
        i -= 1
        break
      end
    end

    flow!(i, j)
  end

  def trickle_from(i, j)
    return if @trickled_from.include?([i, j])
    @trickled_from << [i, j]
    # how does source trickle down?
    # it goes straight down until it hits a wall
    # @debug_mode = true if i > 1900
    # if @debug_mode
    #   temp = self[i, j]
    #   self[i, j] = 'X'
    #   print_grid
    #   self[i, j] = temp
    #   binding.pry
    # end

    loop do
      i += 1
      return unless in_range?(i, j)
      if self[i, j] == EMPTY
        self[i, j] = DOWNTRICKLE
      elsif BUILDABLE.include?(self[i, j])
        i -= 1
        break
      end
    end

    flow!(i, j)
  end

  def flow!(i, j)
    return unless self[i, j] == DOWNTRICKLE

    if both_sides_bounded?(i, j)
      settle_on!(i, j)
      flow!(i - 1, j)
    else
      downtrickle_both_sides!(i, j)
      flow!(i - 1, j) if both_sides_bounded?(i, j)
    end
  end

  def settle_on!(i, j)
    loop do
      j -= 1
      break if self[i, j] == BOUNDARY
      self[i, j] = SETTLED
    end

    loop do
      j += 1
      break if self[i, j] == BOUNDARY
      self[i, j] = SETTLED
    end
  end

  def both_sides_bounded?(i, j)
    orig_j = j
    loop do
      j -= 1
      return false unless in_range?(i, j)
      return false unless BUILDABLE.include?(self[i + 1, j])
      break if self[i, j] == BOUNDARY
    end

    j = orig_j

    loop do
      j += 1
      return false unless in_range?(i, j)
      return false unless BUILDABLE.include?(self[i + 1, j])
      break if self[i, j] == BOUNDARY
    end

    true
  end

  def downtrickle_both_sides!(i, j)
    orig_j = j
    loop do
      j -= 1
      break unless in_range?(i, j)
      break if self[i, j] == BOUNDARY
      self[i, j] = DOWNTRICKLE
      if !BUILDABLE.include?(self[i + 1, j])
        trickle_from(i, j)
        break
      end
    end

    j = orig_j

    loop do
      j += 1
      break unless in_range?(i, j)
      break if self[i, j] == BOUNDARY
      self[i, j] = DOWNTRICKLE
      if !BUILDABLE.include?(self[i + 1, j])
        trickle_from(i, j)
        break
      end
    end
  end

  def total_count
    @grid[@min_y..@max_y].map { |row| row.count { |c| [SETTLED, DOWNTRICKLE].include?(c) } }.sum
  end

  def count_settled
    @grid[@min_y..@max_y].map { |row| row.count(SETTLED) }.sum
  end

  def [](i, j)
    @grid[i][j]
  end

  def []=(i, j, val)
    @grid[i][j] = val
  end
end

input = File.read('input17.txt')

r = Reservoir.new(input)
r.first_trickle(0, 500)
puts r.total_count

# Part 2
puts "Part 2"

puts r.count_settled
