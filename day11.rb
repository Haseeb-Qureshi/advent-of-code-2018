# Find the fuel cell's rack ID, which is its X coordinate plus 10.
# Begin with a power level of the rack ID times the Y coordinate.
# Increase the power level by the value of the grid serial number (your puzzle input).
# Set the power level to itself multiplied by the rack ID.
# Keep only the hundreds digit of the power level (so 12345 becomes 3; numbers with no hundreds digit become 0).
# Subtract 5 from the power level.

# Part 1
puts "Part 1"

SERIAL_NUMBER = 3628
grid = Array.new(301) { Array.new(301) }

1.upto(300) do |y|
  1.upto(300) do |x|
    rack_id = x + 10
    power_level = rack_id * y + SERIAL_NUMBER
    power_level *= rack_id
    power_level = (power_level / 100) % 10
    power_level -= 5

    grid[y][x] = power_level
  end
end

max = 0
max_coords = [1, 1]

size = 3
offset = size - 1
1.upto(300 - offset) do |y|
  1.upto(300 - offset) do |x|
    powers = grid[y..y + offset].map { |slice| slice[x..x + offset].reduce(:+) }
    sum = powers.reduce(:+)

    if sum > max
      max_coords = [x, y]
      max = sum
    end
  end
end

puts max_coords.join(',')

# Part 2
puts "Part 2"

max_coords = [1, 1]
max = 0
optimal_size = 0

1.upto(20) do |size|
  offset = size - 1
  1.upto(300 - offset) do |y|
    1.upto(300 - offset) do |x|
      powers = grid[y..y + offset].map { |slice| slice[x..x + offset].reduce(:+) }
      sum = powers.reduce(:+)

      if sum > max
        max_coords = [x, y]
        max = sum
        optimal_size = size
      end
    end
  end
end

puts [*max_coords, optimal_size].join(',')
