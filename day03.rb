 # A claim like #123 @ 3,2: 5x4 means that claim ID 123 specifies a rectangle 3 inches from the left edge, 2 inches from the top edge, 5 inches wide, and 4 inches tall. Visually, it claims the square inches of fabric represented by # (and ignores the square inches of fabric represented by .) in the diagram below:
#
# If the Elves all proceed with their own plans, none of them will have enough fabric. How many square inches of fabric are within two or more claims?

# Part 1
puts "Part 1"
INPUT = File.readlines('input03.txt').map(&:chomp).map do |line|
  id, _, start, dimensions = line.split
  x, y = start.split(',').map(&:to_i)
  width, height = dimensions.split('x').map(&:to_i)
  [id, x, y, height, width]
end

grid = Array.new(1000) { Array.new(1000, 0) }
INPUT.each do |id, x, y, height, width|
  y.upto(y + height - 1) do |i|
    x.upto(x + width - 1) do |j|
      grid[i][j] += 1
    end
  end
end

puts grid.flatten.count { |sq| sq > 1 }

# One claim doesn't overlap at all. Which one is it?
# Part 2
puts "Part 2"

intact = INPUT.find do |id, x, y, height, width|
  all_intact = true
  y.upto(y + height - 1) do |i|
    x.upto(x + width - 1) do |j|
      if grid[i][j] > 1
        all_intact = false
        break
      end
    end
    break if all_intact == false
  end
  all_intact
end

puts intact.first
