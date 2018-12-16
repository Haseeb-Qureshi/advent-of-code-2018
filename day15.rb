require_relative 'day15_objects'

INPUT = File.read('input15.txt').freeze

# Part 1
puts "Part 1"
Game.new(INPUT, print: false).play

# Part 2
puts "Part 2"

def part2
  elf_strength = 3
  loop do
    begin
      Game.new(INPUT, part2: true, print: false, elf_power: elf_strength).play
      break
    rescue
      puts "Strength of #{elf_strength} didn't work, trying #{elf_strength + 1}"
      elf_strength += 1
    end
  end
end

part2
