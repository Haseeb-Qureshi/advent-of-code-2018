# Part 1
INPUT = File.readlines(__dir__ + "/day01_input.txt").map(&:chomp).map(&:to_i)
puts "Part 1: #{INPUT.reduce(:+)}"

# Part 2
require 'set'
require 'pry'

puts "Part 2"
previously_seen = Set.new([0])
i = 0
sum = 0
loop do
  sum += INPUT[i]
  if previously_seen.include?(sum)
    puts "Found #{sum}"
    break
  end

  previously_seen << sum

  i += 1
  i = 0 if i == INPUT.length
end
