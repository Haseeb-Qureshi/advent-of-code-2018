require_relative 'day16_opcodes'
require 'colorize'

# Part 1
puts "Part 1"

REG = [0, 0, 0, 0, 0, 0]
input = File.read('input21.txt')

instructions = input.lines.map(&:chomp)
instruction_pointer = instructions.shift.split.last.to_i

def parse_instruction(instruction)
  opcode, a, b, c = instruction.split
  a, b, c = [a, b, c].map(&:to_i)
  [opcode.to_sym, a, b, c]
end

instructions.each_with_index do |instr, i|
  opcode, a, b, c = parse_instruction(instr)
  puts [i + 1, TRANSLATIONS[opcode].call(REG, a, b, c).green].join(': ')
end

def compute(instructions, instruction_pointer)
  loop do
    sleep 0.05
    next_instruction = instructions[REG[instruction_pointer]]
    break if next_instruction.nil?
    opcode, a, b, c = parse_instruction(next_instruction)
    OPCODES[opcode].call(REG, a, b, c)
    REG[instruction_pointer] += 1
    puts [REG[instruction_pointer], TRANSLATIONS[opcode].call(REG, a, b, c).green].join(': ')
    puts [[opcode, a, b, c].join(' ').ljust(19, ' ').light_blue, REG.map { |n| n.to_s.rjust(4, '0') }.join(', ')].join(' ' * 8)
    puts "[#{REG.join(', ')}]"
    binding.pry if REG[1] == 28
  end
end

REG = [0, 0, 0, 0, 0, 0]
# compute(instructions, instruction_pointer)

# Part 2
puts "Part 2"

def find_cycle
  @biggest_vals = []
  @bigvals = []

  @my_special_value = 0
  @counter = 0
  @bigval = 65536
  @biggestval = 0
  @working_register = 0

  def do_it
    loop do
      say "Reinitialized!"
      @bigval = @biggestval | 65536 # set the top 18th bit
      @biggestval = 3730679

      do_loop
      do_final_check
      if @working_register == 1
        return "Done!"
      else
        # loop again
      end
    end
  end

  def do_loop
    say "Going into outer loop!"
    loop do
      @working_register = @bigval % 256
      @biggestval += @working_register
      @biggestval &= 16777215
      @biggestval *= 65899
      @biggestval &= 16777215

      if @bigval < 256
        @working_register = 0
        return
      else
        say "Going into inner loop!"
        @working_register = @bigval / 256
        @counter = @working_register + 1
        @counter *= 256

        if @counter > @bigval
          @counter = 1
          @bigval = @working_register
        else
          raise 'wtf'
        end
      end
    end
  end

  def do_final_check
    say "Doing final check!"

    @biggest_vals << @biggestval
    @bigvals << @bigval

    if @biggest_vals.uniq.length == 10165
      puts @biggestval
      @my_special_value = @biggestval
    end

    if @biggestval == @my_special_value
      @working_register = 1
      # done
    else
      @working_register = 0
    end
  end

  def say(s)
    # sleep 0.01
    # puts s
  end

  do_it
end

find_cycle
