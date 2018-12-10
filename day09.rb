# Then, each Elf takes a turn placing the lowest-numbered remaining marble into the circle between the marbles that are 1 and 2 marbles clockwise of the current marble. (When the circle is large enough, this means that there is one marble between the marble that was just placed and the current marble.) The marble that was just placed then becomes the current marble.

# However, if the marble that is about to be placed has a number which is a multiple of 23, something entirely different happens. First, the current player keeps the marble they would have placed, adding it to their score. In addition, the marble 7 marbles counter-clockwise from the current marble is removed from the circle and also added to the current player's score. The marble located immediately clockwise of the marble that was removed becomes the new current marble.

# For example, suppose there are 9 players. After the marble with value 0 is placed in the middle, each player (shown in square brackets) takes a turn. The result of each of those turns would produce circles of marbles like this, where clockwise is to the right and the resulting current marble is in parentheses:

require_relative './utils/linked_list'

# Part 1
puts "Part 1"

INPUT = "424 players; last marble is worth 71482 points"

players, marbles = INPUT.split.select { |word| word[/\d+/] }.map(&:to_i)

def play(players, last_marble)
  marbles = LinkedList.new
  points = [0] * players
  current_marble = nil
  player = 0

  last_marble.times do |i|
    if i == 0
      current_marble = marbles.append(i)
      next
    end

    player = (player + 1) % players

    if i % 23 == 0
      # current player keeps the marble they would have placed, which is added to their score
      points[player] += i

      # marble 7 marbles counter-clockwise is removed from the circle and also added to the player's score
      marble_to_remove = marbles.seek(current_marble, -7)
      points[player] += marble_to_remove.val

      # the marble located immediately clockwise of the marble that was removed becomes the current marble
      current_marble = marbles.delete_and_get_next(marble_to_remove)
    else
      insertion_point = marbles.seek(current_marble, 1)
      current_marble = marbles.append_to(insertion_point, i)
    end
  end
  points.max
end

puts play(players, marbles)

# Part 2
puts "Part 2"

puts play(players, marbles * 100)
