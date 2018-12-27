# The cave is divided into square regions which are either dominantly rocky, narrow, or wet (called its type). Each region occupies exactly one coordinate in X,Y format where X and Y are integers and zero or greater. (Adjacent regions can be the same type.)
#
# The scan (your puzzle input) is not very detailed: it only reveals the depth of the cave system and the coordinates of the target. However, it does not reveal the type of each region. The mouth of the cave is at 0,0.

# The region at 0,0 (the mouth of the cave) has a geologic index of 0.
# The region at the coordinates of the target has a geologic index of 0.
# If the region's Y coordinate is 0, the geologic index is its X coordinate times 16807.
# If the region's X coordinate is 0, the geologic index is its Y coordinate times 48271.
# Otherwise, the region's geologic index is the result of multiplying the erosion levels of the regions at X-1,Y and X,Y-1.
require 'pry'
require 'set'
require_relative 'utils/heap'

# Part 1
puts "Part 1"

 # rocky as ., wet as =, narrow as |, the mouth as M, the target as T,
ROCKY = '.'.freeze
WET = '='.freeze
NARROW = '|'.freeze
MOUTH_GLYPH = 'M'.freeze
TARGET_GLYPH = 'T'.freeze

def set_up_indexes(depth: 11739, target: [11, 718], size_multiplier: 1)
  @target = target
  x, y = @target
  @geologic_indexes = Array.new(y * size_multiplier + 1) { Array.new(x * size_multiplier + 1) }
  @erosion_levels = Array.new(y * size_multiplier + 1) { Array.new(x * size_multiplier + 1) }
  @final_view = Array.new(y * size_multiplier + 1) { Array.new(x * size_multiplier + 1) }

  @final_view[0][0] = MOUTH_GLYPH
  @final_view[y][x] = TARGET_GLYPH

  @geologic_indexes.each_index do |y|
    @geologic_indexes[y].each_index do |x|
      coords = [x, y]
      val = if coords == @target || coords == [0, 0]
        0
      elsif y.zero?
        x * 16807
      elsif x.zero?
        y * 48271
      else
        @erosion_levels[y][x - 1] * @erosion_levels[y - 1][x]
      end

      @geologic_indexes[y][x] = val
      erosion_level = (val + depth) % 20183
      @erosion_levels[y][x] = erosion_level

      next if @final_view[y][x]

      @final_view[y][x] = get_symbol(y, x)
    end
  end
end

def get_symbol(i, j)
  case @erosion_levels[i][j] % 3
  when 0 then ROCKY
  when 1 then WET
  when 2 then NARROW
  else raise 'wtf?'
  end
end

def compute_risk_level
  risk_level = 0
  @erosion_levels.each_index do |i|
    @erosion_levels[i].each_index do |j|
      risk_level += @erosion_levels[i][j] % 3
    end
  end
  risk_level
end

set_up_indexes

# @final_view.each { |row| puts row.join }

puts "Risk level: ", compute_risk_level

# Part 2
puts "Part 2"

CLIMBING_GEAR = 'C'.freeze
TORCH = 'H'.freeze
NEITHER = 'N'.freeze

set_up_indexes(size_multiplier: 3)

def neighbors(i, j)
  [[i + 1, j], [i - 1, j], [i, j + 1], [i, j - 1]].select do |i, j|
    i.between?(0, @geologic_indexes.length - 1) &&
      j.between?(0, @geologic_indexes[0].length - 1)
  end
end

heap = Heap.new([[0, 0, TORCH, 0]]) { |a, b| a.last <=> b.last }
processed = Set.new
best_distances = Hash.new { |h, k| h[k] = [nil, Float::INFINITY] }

until heap.empty?
  i, j, equipment, dist = heap.pop_min
  next if processed.include?([i, j, equipment])

  if [j, i] == @target
    puts "FOUND IT! After #{processed.size} iterations."
    if equipment != TORCH
      puts dist + 7
    else
      puts dist
    end
    break
  end

  neighbors(i, j).each do |i2, j2|
    options = case get_symbol(i2, j2)
    when ROCKY then [CLIMBING_GEAR, TORCH]
    when WET then [CLIMBING_GEAR, NEITHER]
    when NARROW then [TORCH, NEITHER]
    end

    candidates = options.reject do |new_equipment|
      processed.include?([i2, j2, new_equipment])
    end.map do |new_equipment|
      if new_equipment != equipment
        [i2, j2, new_equipment, dist + 8]
      else
        [i2, j2, new_equipment, dist + 1]
      end
    end

    candidates.each do |cand|
      heap << cand
      i2, j2, new_equipment, new_dist = cand

      if dist < best_distances[[i2, j2, new_equipment]][1]
        best_distances[[i2, j2, new_equipment]] = [[i, j, equipment], new_dist]
      end
    end
  end

  processed << [i, j, equipment]
end
