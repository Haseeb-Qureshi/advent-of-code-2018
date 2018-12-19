require_relative 'day16_opcodes'
require 'colorize'
# Part 1
puts "Part 1"

REG = [0, 0, 0, 0, 0, 0]
input = "#ip 0
seti 5 0 1
seti 6 0 2
addi 0 1 0
addr 1 2 3
setr 1 0 0
seti 8 0 4
seti 9 0 5"
input = File.read('input19.txt')

instructions = input.lines.map(&:chomp)

instruction_pointer = instructions.shift.split.last.to_i

def parse_instruction(instruction)
  opcode, a, b, c = instruction.split
  a, b, c = [a, b, c].map(&:to_i)
  [opcode.to_sym, a, b, c]
end

loop do
  next_instruction = instructions[REG[instruction_pointer]]
  break if next_instruction.nil?
  opcode, a, b, c = parse_instruction(next_instruction)
  OPCODES[opcode].call(REG, a, b, c)
  REG[instruction_pointer] += 1
end

puts REG[0]

Part 2
puts "Part 2"

REG = [1, 0, 0, 0, 0, 0]

def interpret_translation(translation, instruction_pointer)
  translation.gsub("Reg #{instruction_pointer}", "IP")
end

50.times do
  next_instruction = instructions[REG[instruction_pointer]]
  opcode, a, b, c = parse_instruction(next_instruction)
  OPCODES[opcode].call(REG, a, b, c)
  REG[instruction_pointer] += 1
end

number_to_factor = REG[1]
puts 1.upto(REG[1]).select { |i| REG[1] % i == 0 }.sum
