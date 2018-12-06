# Part 1
puts "Part 1"

def switch_case?(a, b)
  lower, higher = [a, b].map(&:ord).sort
  lower <= 90 && higher >= 97
end

INPUT = File.read('input05.txt')

def react(input)
  polymer = []

  input.each_char do |char|
    polymer << char
    next if polymer.length == 1 # Skip loop first iteration

    loop do
      break if polymer.length < 2

      prev = polymer[-2]
      curr = polymer[-1]
      break unless switch_case?(prev, curr)
      break unless prev.downcase == curr.downcase
      2.times { polymer.pop }
    end
  end

  polymer
end

puts react(INPUT).length

# Part 2
puts "Part 2"

improved_polymer_lengths = ('a'..'z').map do |char|
  cleaned_string = INPUT.delete(char).delete(char.upcase)
  react(cleaned_string).length
end

puts improved_polymer_lengths.min
