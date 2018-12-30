require 'pry'
require 'set'

# Part 1
puts "Part 1"

PRINT = false

INPUT = File.read('input24.txt')

INPUT = "Immune System:
17 units each with 5390 hit points (weak to radiation, bludgeoning) with an attack that does 4507 fire damage at initiative 2
989 units each with 1274 hit points (immune to fire; weak to bludgeoning, slashing) with an attack that does 25 slashing damage at initiative 3

Infection:
801 units each with 4706 hit points (weak to radiation) with an attack that does 116 bludgeoning damage at initiative 1
4485 units each with 2961 hit points (immune to radiation; weak to fire, cold) with an attack that does 12 slashing damage at initiative 4"

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
    return 0 if opponent.nil?

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
    # The attacking group chooses to target the group in the enemy army to which it would deal the most damage (after accounting for weaknesses and immunities, but not accounting for whether the defending group has enough units to actually receive all of that damage).

    # If an attacking group is considering two defending groups to which it would deal equal damage, it chooses to target the defending group with the largest effective power; if there is still a tie, it chooses the defending group with the highest initiative. If it cannot deal any defending groups damage, it does not choose a target. Defending groups can only be chosen as a target by one attacking group.

    target = opponents.max_by do |opponent|
      damage = damage_to(opponent)
      puts "#{type} group #{num} would deal defending group #{opponent.num} #{damage} damage" if PRINT
      [damage_to(opponent), opponent.effective_power, opponent.initiative]
    end

    @target = damage_to(target).zero? ? nil : target
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

immune_str, infection_str = INPUT.split("\n\n")

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

def print_groups(round, immune_groups, infection_groups)
  return unless PRINT

  puts "-" * 12
  puts "Round #{round}"
  puts "-" * 12
  puts "Immune System:"
  immune_groups.each do |group|
    puts "Group #{group.num} contains #{group.units} units"
  end

  puts "Infection:"
  infection_groups.each do |group|
    puts "Group #{group.num} contains #{group.units} units"
  end
end

immune_groups = process_groups(immune_str)
infection_groups = process_groups(infection_str)

round = 0
print_groups(round, immune_groups, infection_groups)

until immune_groups.empty? || infection_groups.empty?
  round += 1

  untargeted_immunes = immune_groups.dup
  infection_groups.sort_by { |g| [g.effective_power, g.initiative] }
                  .reverse_each do |infection_group|
                    target = infection_group.select_target!(untargeted_immunes)
                    untargeted_immunes.delete(target)
                  end

  untargeted_infections = infection_groups.dup
  immune_groups.sort_by { |g| [g.effective_power, g.initiative] }
               .reverse_each do |immune_group|
                 target = immune_group.select_target!(untargeted_infections)
                 untargeted_infections.delete(target)
               end

  puts "\n" if PRINT

  (immune_groups + infection_groups).sort_by(&:initiative).reverse_each do |group|
    if group.dead?
      immune_groups.delete(group)
      infection_groups.delete(group)
    else
      group.attack_target!
    end
  end

  print_groups(round, immune_groups, infection_groups)
end

# 17041 is too low
# 17050 is too low
# 17100 is too low
puts [immune_groups.map(&:units), infection_groups.map(&:units)].flatten.sum
