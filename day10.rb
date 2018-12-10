# position=< 21188,  31669> velocity=<-2, -3>
# position=<-10416, -31455> velocity=< 1,  3>
# position=< 21144, -31450> velocity=<-2,  3>
# Part 1
puts "Part 1"

EMPTY = '.'.freeze
INPUT = File.readlines('input10.txt').map(&:chomp)

original_points = INPUT.map do |line|
  line.scan(/-?\d+/).map(&:to_i)
end

working_points = INPUT.map do |line|
  line.scan(/-?\d+/).map(&:to_i)
end

def range(points)
  points.map { |point| point[1] }.minmax.reduce(:-).abs
end

def print_points(points)
  xs_and_ys = points.map { |point| point.first(2) }
  min_x = xs_and_ys.map(&:first).min
  min_y = xs_and_ys.map(&:last).min

  points.each do |point|
    point[0] -= min_x
    point[1] -= min_y
  end

  max_x = points.max_by { |x, y, dx, dy| x }[0]
  max_y = points.max_by { |x, y, dx, dy| y }[1]

  grid = Array.new(max_y + 1) { Array.new(max_x + 1, EMPTY) }

  points.each do |x, y, dx, dy|
    grid[y][x] = '#'
  end

  puts "-" * 15
  grid.each do |row|
    puts row.join
  end
  puts "-" * 15
end

def find_tightest_range(points, iterations = 20_000, should_print = false)
  ranges = []
  0.upto(iterations) do |i|
    points.each do |point|
      x, y, dx, dy = point
      point[0] += dx
      point[1] += dy
    end

    ranges << [i, range(points)]
  end
  print_points(points) if should_print
  ranges.min_by(&:last)
end


iterations, range = find_tightest_range(working_points)
puts iterations, range

find_tightest_range(original_points, iterations, true)
