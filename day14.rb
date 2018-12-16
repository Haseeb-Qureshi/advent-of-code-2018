# To create new recipes, the two Elves combine their current recipes. This creates new recipes from the digits of the sum of the current recipes' scores.

# After all new recipes are added to the scoreboard, each Elf picks a new current recipe. To do this, the Elf steps forward through the scoreboard a number of recipes equal to 1 plus the score of their current recipe. So, after the first round, the first Elf moves forward 1 + 3 = 4 times, while the second Elf moves forward 1 + 7 = 8 times. If they run out of recipes, they loop back around to the beginning. After the first round, both Elves happen to loop around until they land on the same recipe that they had in the beginning; in general, they will move to different recipes.

# Part 1
puts "Part 1"

iterations = 765071
recipes = [3, 7]
elf1 = 0
elf2 = 1

(iterations + 10).times do
  new_recipes = recipes.values_at(elf1, elf2)
                       .reduce(:+)
                       .digits
                       .reverse!

  recipes.concat(new_recipes)


  elf1 = (elf1 + recipes[elf1] + 1) % recipes.length
  elf2 = (elf2 + recipes[elf2] + 1) % recipes.length
end

puts recipes[iterations...iterations + 10].join


# Part 2
puts "Part 2"

goal = 765071.to_s
recipes = [3, 7]
tail = []
elf1 = 0
elf2 = 1
loop do
  new_recipes = recipes.values_at(elf1, elf2)
                       .reduce(:+)
                       .digits
                       .reverse!

  tail.concat(new_recipes)
  tail.shift until tail.length < 9

  break if tail.join.include?(goal)

  new_recipes.each { |el| recipes << el }

  elf1 = (elf1 + recipes[elf1] + 1) % recipes.length
  elf2 = (elf2 + recipes[elf2] + 1) % recipes.length
end

puts recipes.length - 5
