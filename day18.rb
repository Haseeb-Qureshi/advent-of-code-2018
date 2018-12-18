# The lumber collection area is 50 acres by 50 acres; each acre can be either open ground (.), trees (|), or a lumberyard (#). You take a scan of the area (your puzzle input).

# An open acre will become filled with trees if three or more adjacent acres contained trees. Otherwise, nothing happens.
# An acre filled with trees will become a lumberyard if three or more adjacent acres were lumberyards. Otherwise, nothing happens.
# An acre containing a lumberyard will remain a lumberyard if it was adjacent to at least one other lumberyard and at least one acre containing trees. Otherwise, it becomes open.

require 'set'
require 'digest'

# Part 1
puts "Part 1"

class LumberYard
  GROUND = '.'.freeze
  TREE = '|'.freeze
  LUMBER = '#'.freeze

  def initialize
    @grid = File.readlines('input18.txt').map(&:chomp).map(&:chars)
    @count = 0
    @hashes = Set.new
  end

  def in_range?(i, j)
    i.between?(0, @grid.length - 1) && j.between?(0, @grid[0].length - 1)
  end

  def adjacents(i, j, grid)
    [
      [i - 1, j - 1],
      [i - 1, j],
      [i - 1, j + 1],
      [i, j - 1],
      [i, j + 1],
      [i + 1, j - 1],
      [i + 1, j],
      [i + 1, j + 1],
    ].select { |i, j| in_range?(i, j) }
     .map { |i, j| grid[i][j] }
  end

  def cloned_grid
    @grid.map(&:dup)
  end

  def transition(temp_grid, i, j)
    this_acre = temp_grid[i][j]
    if this_acre == GROUND
      if adjacents(i, j, temp_grid).count { |c| c == TREE } >= 3
        @grid[i][j] = TREE
      end
    elsif this_acre == TREE
      if adjacents(i, j, temp_grid).count { |c| c == LUMBER } >= 3
        @grid[i][j] = LUMBER
      end
    elsif this_acre == LUMBER
      adjs = adjacents(i, j, temp_grid)
      if adjs.count { |c| c == LUMBER } > 0 && adjs.count { |c| c == TREE } > 0
        # remain a lumberyard
      else
        @grid[i][j] = GROUND
      end
    end
  end

  def tick
    temp_grid = cloned_grid
    @grid.each_index do |i|
      @grid[0].each_index do |j|
        transition(temp_grid, i, j)
      end
    end

    @count += 1
  end

  def print_grid
    puts
    puts "After minute #{@count}"
    @grid.each { |row| puts row.join }
    puts
  end

  def total_resources
    resources = @grid.flatten
    resources.count { |c| c == LUMBER } * resources.count { |c| c == TREE }
  end

  def compute_period
    loop do
      tick

      hash = Digest::SHA2.hexdigest(@grid.flatten.join)
      if hash == @first_hash
        return @count - @first_hash_count
      end

      if @hashes.include?(hash) && !@first_hash
        @first_hash = hash
        @first_hash_count = @count
      end

      @hashes << hash
    end
  end

  def compute_resources_at(n)
    period = compute_period
    remaining_distance = n - @count
    (remaining_distance % period).times { tick }
    total_resources
  end
end

lumberyard = LumberYard.new
10.times { lumberyard.tick }
puts lumberyard.total_resources

# Part 2
puts "Part 2"
puts LumberYard.new.compute_resources_at(1_000_000_000)
