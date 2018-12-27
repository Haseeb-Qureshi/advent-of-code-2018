require 'pry'
require 'set'
# Part 1
puts "Part 1"

INPUT = File.read('input23.txt')
ORIGIN = [0, 0, 0]
POINTS = INPUT.lines.map { |line| line.scan(/-?\d+/).map(&:to_i) }
strongest = POINTS.sort_by!(&:last).last # strongest

def manhattan_distance(point1, point2)
  x, y, z, _ = point1
  x2, y2, z2, _ = point2

  (x - x2).abs + (y - y2).abs + (z - z2).abs
end

def in_range_of?(point1, point2)
  r = point1.last
  manhattan_distance(point1, point2) <= r
end

puts POINTS.count { |point| in_range_of?(strongest, point) }

# Part 2
puts "Part 2"

def intersection_count(point)
  POINTS.count { |point2| in_range_of?(point2, point) }
end

# hillclimb from the point with the most intersections
def neighbors(point, step: 1)
  x, y, z, _ = point
  [
    [x + step, y, z],
    [x, y + step, z],
    [x, y, z + step],
    [x - step, y, z],
    [x, y - step, z],
    [x, y, z - step]
  ]
end

def find_best_spot(start, step)
  current = start.first(3)
  current_intersections = intersection_count(current)
  queue = [[current, current_intersections]]
  seen = Set.new
  enqueued = Set.new
  best = [current, [current_intersections, -manhattan_distance(ORIGIN, current)]]

  until queue.empty?
    this, this_intersections = queue.shift
    next if seen.include?(this)

    neighbors(this, step: step).each do |neighbor|
      next if enqueued.include?(neighbor)
      next if seen.include?(neighbor)

      intersections = intersection_count(neighbor)
      enqueued << neighbor
      if intersections > this_intersections
        queue << [neighbor, intersections]
        new = [neighbor, [intersections, -manhattan_distance(ORIGIN, neighbor)]]
        best = [best, new].max_by(&:last)
      elsif intersections == this_intersections
        if manhattan_distance(ORIGIN, neighbor) < manhattan_distance(ORIGIN, this)
          queue << [neighbor, intersections]
          new = [neighbor, [intersections, -manhattan_distance(ORIGIN, neighbor)]]
          best = [best, new].max_by(&:last)
        end
      end
    end
    seen << this
  end
  best
end

# See which point intersects with the most other points
most_intersections = POINTS.max_by { |point| intersection_count(point) }


round1, _ = find_best_spot(most_intersections, 10_000)
round2, _ = find_best_spot(round1, 1_000)
round3, _ = find_best_spot(round2, 100)
round4, _ = find_best_spot(round3, 10)
round5, data = find_best_spot(round4, 1)

intersections, dist = data

puts -dist
