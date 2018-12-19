require 'set'
require_relative 'day16_opcodes'

# Part 1
puts "Part 1"

REG = [0, 0, 0, 0]
INPUT = File.readlines('input16.txt').map(&:chomp).reject(&:empty?)

samples = []
INPUT.each_slice(3) do |before, code, after|
  break unless before.start_with?('Before')
  sample = []
  sample << before.scan(/\d+/).map(&:to_i)
  sample << code.split.map(&:to_i)
  sample << after.scan(/\d+/).map(&:to_i)
  samples << sample
end

def num_valid_opcodes(before, code, after)
  OPCODES.select do |opcode, fn|
    original_register = before.dup
    fn.call(original_register, *code.drop(1))
    original_register == after
  end.count
end

count = samples.select do |before, code, after|
  num_valid_opcodes(before, code, after) >= 3
end.count

puts count

# Part 2
puts "Part 2"

possibilities = Hash.new { |h, k| h[k] = Set.new }
certainties = {}
samples.each do |before, code, after|
  matches = []
  OPCODES.each do |opcode, fn|
    register = before.dup
    fn.call(register, *code.drop(1))
    matches << opcode if register == after
  end

  if matches.length == 1
    possibilities.delete(matches[0])
    certainties[code[0]] = matches[0]
  else
    unless certainties.has_key?(code[0])
      matches.each { |match| possibilities[code[0]] << match }
    end
  end
end

certainties.each do |k, v|
  possibilities.each_value { |s| s.delete(v) }
  possibilities[k] << v
end

ordered_possibilities = possibilities.map { |k, v| [k, v.to_a] }

def satisfy_constraints(possible_values, assignments = {}, already_assigned = Set.new)
  return assignments if possible_values.empty?

  num, possible_opcodes = possible_values.first

  possible_opcodes.each do |opcode|
    next if already_assigned.include?(opcode)
    # try assignment
    assignments[num] = opcode
    already_assigned << opcode
    satisfaction = satisfy_constraints(possible_values.drop(1), assignments, already_assigned)

    if satisfaction
      return satisfaction
    else
      # no satisfaction
      assignments.delete(num)
      already_assigned.delete(opcode)
    end
  end

  false
end

true_codes = satisfy_constraints(ordered_possibilities)

# Now let's run the program!
registers = [0, 0, 0, 0]

program = File.read('input16.txt')
              .split("\n\n\n\n")
              .last
              .lines
              .map(&:chomp)
              .reject(&:empty?)
              .map(&:split)
              .map { |arr| arr.map(&:to_i) }

program.each do |opcode, a, b, c|
  OPCODES[true_codes[opcode]].call(registers, a, b, c)
end

puts registers[0]
