require 'pry'
require 'set'

# Part 1
puts "Part 1"

PRINT = false

INPUT = File.read('input24.txt')

class UnitGroup < Struct.new(
  :type,
  :units,
  :hp,
  :immunities,
  :weaknesses,
  :damage_power,
  :damage_type,
  :initiative,
  :num
)
  attr_reader :target

  def effective_power
    units * damage_power
  end

  def effective_hp
    units * hp
  end

  def receive_damage!(damage)
    if effective_hp - damage <= 0
      self.units = 0
    else
      units_lost = damage / hp
      self.units -= units_lost
    end
  end

  def damage_to(opponent)
    if opponent.immunities.include?(damage_type)
      0
    elsif opponent.weaknesses.include?(damage_type)
      effective_power * 2
    else
      effective_power
    end
  end

  def dead?
    units.zero?
  end

  def select_target!(opponents)
    return nil if opponents.empty?

    target = opponents.max_by do |opponent|
      raise "WTF, opponent is dead" if opponent.dead?

      damage = damage_to(opponent)
      puts "#{type} group #{num} would deal defending group #{opponent.num} #{damage} damage" if PRINT
      [damage_to(opponent), opponent.effective_power, opponent.initiative]
    end

    @target = target unless damage_to(target).zero?
  end

  def attack_target!
    if @target && !@target.dead?
      original_units = @target.units
      @target.receive_damage!(damage_to(@target))
      puts "#{type} group #{num} attacks defending group #{@target.num}, killing #{original_units - @target.units} units" if PRINT
    end

    @target = nil
  end
end


class Game
  def initialize(boost_immune: 0)
    @boost_immune = boost_immune

    immune_str, infection_str = INPUT.split("\n\n")
    @immune_groups = process_groups(immune_str)
    @infection_groups = process_groups(infection_str)
    @round = 0

    print_groups
  end

  def play_out!
    until @immune_groups.sum(&:units).zero? || @infection_groups.sum(&:units).zero?
      total_units = final_score
      fight_round!
      break if final_score == total_units # stalemate!
    end
  end

  def fight_round!
    @round += 1
    target_selection!
    puts "\n" if PRINT
    attack_targets!
    print_groups
  end

  def final_score
    [*@immune_groups, *@infection_groups].sum(&:units)
  end

  def winner
    if @infection_groups.sum(&:units) > 0
      :Infection
    else
      :Immune
    end
  end

  private

  def target_selection!
    begin
    untargeted_immunes = @immune_groups.dup
    @infection_groups.sort_by { |g| [g.effective_power, g.initiative] }
                     .reverse_each do |infection_group|
                       target = infection_group.select_target!(untargeted_immunes)
                       untargeted_immunes.delete(target)
                     end

    untargeted_infections = @infection_groups.dup
    @immune_groups.sort_by { |g| [g.effective_power, g.initiative] }
                  .reverse_each do |immune_group|
                    target = immune_group.select_target!(untargeted_infections)
                    untargeted_infections.delete(target)
                  end
                rescue => e
                  binding.pry
                end
  end

  def attack_targets!
    (@immune_groups + @infection_groups).sort_by(&:initiative).reverse_each do |group|
      next if group.dead?

      target = group.target
      next if target.nil?

      group.attack_target!
      if target.dead?
        @immune_groups.delete(target)
        @infection_groups.delete(target)
      end
    end
  end

  def process_groups(s)
    type = s.split(':').first.to_sym
    s.lines.drop(1).each_with_index.reduce([]) do |arr, (line, i)|
      units = line.scan(/(\d+) units/).flatten.first.to_i
      hp = line.scan(/(\d+) hit points/).flatten.first.to_i

      characteristics = line[/\(.+\)/]

      if characteristics
        immunities = characteristics.scan(/immune to ([^;\)]+)/).flatten.first
        weaknesses = characteristics.scan(/weak to ([^;\)]+)/).flatten.first
      else
        immunities = nil
        weaknesses = nil
      end

      if immunities
        immunities = immunities.split(', ').map(&:to_sym)
      else
        immunities = []
      end

      if weaknesses
        weaknesses = weaknesses.split(', ').map(&:to_sym)
      else
        weaknesses = []
      end

      damage_power = line.scan(/attack that does (\d+)/).flatten.first.to_i
      damage_type = line.scan(/attack that does \d+ (\w+) damage/).flatten.first.chomp.to_sym
      initiative = line.scan(/at initiative (\d+)/).flatten.first.to_i
      num = i + 1

      damage_power += @boost_immune unless type == :Infection

      arr << UnitGroup.new(
        type,
        units,
        hp,
        immunities,
        weaknesses,
        damage_power,
        damage_type,
        initiative,
        num
      )
    end

  end

  def print_groups
    return unless PRINT

    puts "-" * 12
    puts "Round #{@round}"
    puts "-" * 12
    puts "Immune System:"
    @immune_groups.each do |group|
      puts "Group #{group.num} contains #{group.units} units"
    end

    puts "Infection:"
    @infection_groups.each do |group|
      puts "Group #{group.num} contains #{group.units} units"
    end
  end
end

g = Game.new
g.play_out!
puts g.final_score

# Part 2
puts "Part 2"

minimal_winning_boost = (1..).find do |boost|
  g = Game.new(boost_immune: boost)
  g.play_out!
  g.winner != :Infection
end

puts minimal_winning_boost
