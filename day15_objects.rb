require 'set'
require 'pry'
require 'benchmark'

WALL = '#'.freeze
EMPTY = '.'.freeze

class GameOverError < StandardError; end
class ElfDeathError < StandardError; end

class Game
  attr_reader :turns, :elf_power
  def initialize(input, print: true, part2: false, elf_power: 3)
    @input = input
    @grid = Grid.new(input, self, part2)
    @turns = 0
    @print = print
    @part2 = part2
    @elf_power = elf_power
  end

  def play
    print_game
    begin
      loop do
        take_turn
        @turns += 1
      end
    rescue GameOverError
      puts "Incomplete final round..."
    end

    puts "And done!!"
    puts calc_points
    puts [@grid.units.map(&:hp).sum, @turns]
  end

  def calc_points
    @grid.units.map(&:hp).sum * @turns
  end

  def take_turn
    @grid.move_each_unit!
    print_game
  end

  def print_game
    puts to_s if @print
  end

  def to_s
    output = []
    if @turns == 0
      output << "Initially:"
    else
      output << "After #{@turns} rounds:"
    end

    @grid.grid.each do |row|
      units = row.select { |el| el.is_a?(Unit) }
      s = row.join
      healths = units.map { |u| "#{u}(#{u.hp})" }.join(', ')
      output << [s, healths].join('   ')
    end

    output.join("\n")
  end

  def inspect
    to_s
  end
end

class Grid
  attr_reader :grid, :units, :goblin_count, :elf_count, :game

  def initialize(input, game, part2)
    @game = game
    @units = []
    @goblin_count = 0
    @elf_count = 0
    @part2 = part2
    @grid = input.lines.map(&:chomp).reject(&:empty?).map.with_index do |line, i|
      line.chars.map.with_index do |char, j|
        case char
        when 'G'
          @goblin_count += 1
          Goblin.new(self, i, j).tap { |g| @units << g }
        when 'E'
          @elf_count += 1
          Elf.new(self, i, j).tap { |e| @units << e }
        else char
        end
      end
    end
  end

  def move_each_unit!
    @units.sort_by(&:coords).each do |unit|
      next if unit.dead?
      raise GameOverError if game_over?

      attacked = try_attacking!(unit)
      next if attacked

      next_square = choose_location(unit)
      move_unit!(unit, next_square)
      try_attacking!(unit)
    end
  end

  private

  def game_over?
    goblin_count.zero? || elf_count.zero?
  end

  def choose_location(unit)
    # BFS to find the closest opponent, then find every path there, taking the minimum lexicographical next step in that direction
    origin = unit.coords
    opponents = units.select { |u| u.class == unit.enemy }.reject(&:dead?)
    target_squares = Set.new(opponents.flat_map { |u| reachable_empty_squares(u.coords) })

    return origin if target_squares.empty?

    seen = {}
    queue = [[origin, nil]]
    enqueued = Set.new([origin])
    goal = nil
    while queue.any?
      square, predecessor = queue.shift

      seen[square] = predecessor
      if target_squares.include?(square)
        goal = square
        break
      end

      next_squares = reachable_empty_squares(square).reject do |sq|
        seen.key?(sq) || enqueued.include?(sq)
      end.sort

      queue.concat(next_squares.map { |sq| [sq, square] })
      next_squares.each { |sq| enqueued << sq }
    end

    # if no path leads to any of our targets, then no-op
    return origin if goal.nil?

    goal = seen[goal] until reachable_empty_squares(origin).include?(goal)
    goal
  end

  def move_unit!(unit, next_square)
    i, j = next_square
    self[unit.i, unit.j] = EMPTY
    self[i, j] = unit
    unit.i = i
    unit.j = j
  end

  def try_attacking!(unit)
    can_attack = []

    valid(unit.neighbors).each do |coord|
      can_attack << self[*coord] if self[*coord].class == unit.enemy
    end

    return false if can_attack.none?
    # now actually attack the fucker
    target = can_attack.min_by { |unit| [unit.hp, unit.i, unit.j] }
    target.get_hit(unit)

    register_death!(target) if target.dead?
    true
  end

  def register_death!(unit)
    raise ElfDeathError.new if unit.is_a?(Elf) && @part2
    self[unit.i, unit.j] = EMPTY
    @units.delete(unit)
    unit.is_a?(Goblin) ? @goblin_count -= 1 : @elf_count -= 1
  end

  def valid(coords)
    coords.select do |i, j|
      i.between?(0, @grid.length - 1) && j.between?(0, @grid[0].length - 1)
    end
  end

  def reachable_empty_squares(coords)
    valid(self.class.neighbors(*coords)).select { |i, j| self[i, j] == EMPTY }
  end

  def [](i, j)
    @grid[i][j]
  end

  def []=(i, j, val)
    @grid[i][j] = val
  end

  def self.neighbors(i, j)
    [[i - 1, j], [i, j - 1], [i, j + 1], [i + 1, j]]
  end
end

class Unit
  attr_accessor :i, :j, :hp, :grid, :game
  def initialize(grid, i, j)
    @grid = grid
    @game = grid.game
    @i = i
    @j = j
    @hp = 200
  end

  def dead?
    hp <= 0
  end

  def coords
    [i, j]
  end

  def neighbors
    Grid.neighbors(i, j)
  end

  def get_hit(by)
    @hp -= by.attack_power
  end

  def inspect
    "#{self.class}: [#{i}, #{j}] — #{hp} HP"
  end
end

class Goblin < Unit
  def enemy
    Elf
  end

  def attack_power
    3
  end

  def to_s
    'G'
  end
end

class Elf < Unit
  def enemy
    Goblin
  end

  def attack_power
    game.elf_power
  end

  def to_s
    'E'
  end
end
