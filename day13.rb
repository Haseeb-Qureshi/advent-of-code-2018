# Each time a cart has the option to turn (by arriving at any intersection), it turns left the first time, goes straight the second time, turns right the third time, and then repeats those directions starting again with left the fourth time, straight the fifth time, and so on.

# left, straight, right

# state per square: [cart (has dir), underneath]

# Part 1
puts "Part 1"

require_relative 'day13_cart'

INPUT = File.read('input13.txt')

def initialize_grid_and_carts
  grid = INPUT.gsub('|', '.')
              .gsub('-', '.')
              .lines
              .map(&:chomp)
              .reject(&:empty?)
              .map(&:chars)

  carts = []
  grid.each_index do |i|
    grid[i].each_index do |j|
      next unless Cart::ORIENTATIONS.include?(grid[i][j])

      # it's a cart, so build it and replace it
      carts << [Cart.new(grid[i][j]), [i, j]]
      grid[i][j] = '.'
    end
  end

  [grid, carts]
end

grid, carts = initialize_grid_and_carts

ticks = 0
x, y, new_x, new_y = nil
loop do
  begin
    carts.each do |cart, coords|
      x, y = coords
      grid[x][y] = cart.underneath
      new_x, new_y = cart.next_square(x, y)

      to = grid[new_x][new_y]
      cart.move!(to)

      coords[0] = new_x
      coords[1] = new_y
      grid[new_x][new_y] = cart.orientation
    end
  rescue Cart::ExplosionError => e
    puts "#{ticks} ticks have passed"
    puts "Location is #{[y, x]} and was moving to #{[new_y, new_x]}"
    break
  end

  carts.sort_by!(&:last)
  ticks += 1
end

# Part 2
puts "Part 2"

grid, carts = initialize_grid_and_carts

ticks = 0
loop do
  i = 0
  while i < carts.length
    cart, coords = carts[i]
    x, y = coords

    grid[x][y] = cart.underneath
    new_x, new_y = cart.next_square(x, y)

    to = grid[new_x][new_y]
    begin
      cart.move!(to)
      coords[0] = new_x
      coords[1] = new_y
      grid[new_x][new_y] = cart.orientation
      i += 1
    rescue Cart::ExplosionError => e
      # remove both carts
      collided, _ = carts.find { |cart, coords| [new_x, new_y] == coords }
      grid[new_x][new_y] = collided.underneath
      to_del = carts.index { |cart_to_delete, _| cart_to_delete == collided }
      i -= 1 if to_del < i
      carts.delete_at(to_del)
      carts.delete_at(i)
    end
  end

  if carts.length == 1
    puts "AND FINITO AT TICK #{ticks}"
    p carts
    break
  end
  carts.sort_by!(&:last)
  ticks += 1
end
