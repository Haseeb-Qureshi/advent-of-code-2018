require 'pry'
require 'set'

# Part 1
puts "Part 1"

INPUT = "pos=<0,0,0>, r=4
pos=<1,0,0>, r=1
pos=<4,0,0>, r=3
pos=<0,2,0>, r=1
pos=<0,5,0>, r=3
pos=<0,0,3>, r=1
pos=<1,1,1>, r=1
pos=<1,1,2>, r=1
pos=<1,3,1>, r=1"

INPUT = File.read('input23.txt')

coords = INPUT.lines.map { |line| line.scan(/\d+/).map(&:to_i) }
x, y, z, r = coords.sort_by!(&:last).last # strongest
binding.pry

count = coords.count do |x2, y2, z2, r2|
  (x - x2).abs + (y - y2).abs + (z - z2).abs <= r
end

puts coords.count

puts count
