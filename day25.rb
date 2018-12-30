# Two points are in the same constellation if their manhattan distance apart is no more than 3 or if they can form a chain of points, each a manhattan distance no more than 3 from the last, between the two of them. (That is, if a point is close enough to a constellation, it "joins" that constellation.)
# Part 1
puts "Part 1"

require 'pry'
require 'set'

INPUT = File.read('input25.txt')

points = INPUT.lines.map do |line|
  line.split(',').map(&:to_i)
end

out_edges = Hash.new { |h, k| h[k] = [] }
in_edges = Hash.new { |h, k| h[k] = [] }


def manhattan_distance(p1, p2)
  p1.zip(p2).map { |x1, x2| (x1 - x2).abs }.sum
end

points.each_index do |i|
  (i + 1).upto(points.length - 1) do |j|
    point1 = points[i]
    point2 = points[j]

    if manhattan_distance(point1, point2) <= 3
      out_edges[point1] << point2
      in_edges[point2] << point1
    end
  end
end

components = 0
seen = Set.new

points.each do |input|
  next if seen.include?(input)

  components += 1
  queue = [input]
  this_component = Set.new
  until queue.empty?
    point = queue.shift
    seen << point
    this_component << point
    (out_edges[point] + in_edges[point]).each do |point2|
      next if this_component.include?(point2)

      if seen.include?(point2) # this is in a previously counted constellation
        components -= 1

        queue = []
        break
      end

      queue << point2
    end
  end
end

puts components

# 617 is too high
