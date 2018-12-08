# 242, 112
# 292, 356
# 66, 265

# What is the size of the largest area that isn't infinite?
require 'set'
require 'pry'

# Part 1
puts "Part 1"

NOPE = "."
def neighbors(i, j)
  [[i + 1, j], [i - 1, j], [i, j + 1], [i, j - 1]]
end

INPUT = File.readlines('input06.txt').map { |s| s.split(',').map(&:to_i) }
min, max = INPUT.flatten.minmax
size = max - min

grid = Array.new(size) { Array.new(size) }

iterations = 0

unique_inputs = INPUT.map.with_index do |(x, y), i|
  [x - min, y - min, (65 + i).chr]
end

queue = unique_inputs.dup
infinite_chars = Set.new

until queue.empty?
  # BFS from each node, one by one
  current_queue = queue.dup

  current_queue.each do |i, j, char|
    if !(i.between?(0, size - 1) && j.between?(0, size - 1))
      # Going out of range; everything belonging to this dude must be dotted out
      infinite_chars << char
    elsif grid[i][j]
      if grid[i][j] == NOPE
        # do nothing
      elsif grid[i][j][0] == iterations # if was created in this round
        grid[i][j] = NOPE if grid[i][j][1] != char # cancel out if overlapping
      end
    else
      grid[i][j] = [iterations, char]
      neighbors(i, j).each do |x, y|
        queue.push([x, y, char])
      end
    end

    queue.shift
  end

  iterations += 1
end

grid.each do |row|
  row.each_index do |i|
    row[i] = NOPE if infinite_chars.include?(row[i][1])
  end
end

puts grid.flatten(1)
         .reject { |s| s == NOPE }
         .map(&:last)
         .group_by { |x| x }
         .map { |k, instances| instances.length }
         .max


# Part 2
puts "Part 2"

grid = Array.new(size) { Array.new(size, false) }
queue << [size / 2, size / 2] # start in the center
seen = Set.new

until queue.empty?
  x, y = queue.shift
  next if seen.include?([x, y])
  next unless x.between?(0, size - 1) && y.between?(0, size - 1)
  next if grid[x][y]

  seen << [x, y]

  dists = unique_inputs.reduce(0) { |acc, (x2, y2)| acc + (x - x2).abs + (y - y2).abs }
  next if dists >= 10_000

  neighbors(x, y).each do |x2, y2|
    queue << [x2, y2]
  end
  grid[x][y] = true
end

puts grid.flatten.count(&:itself)
