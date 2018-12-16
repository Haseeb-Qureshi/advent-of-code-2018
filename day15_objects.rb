require 'set'
require 'pry'
require 'benchmark'

WALL = '#'.freeze
EMPTY = '.'.freeze

class GameOverError < StandardError; end

class Game
  attr_reader :turns
  def initialize(input)
    @grid = Grid.new(input, self)
    @turns = 0
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
  end

  def calc_points
    @grid.units.map(&:hp).sum * @turns
  end

  def take_turn
    time = Benchmark.realtime do
      @grid.move_each_unit!
    end
    puts time
    print_game
  end

  def print_game
    puts to_s
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

  def initialize(input, game)
    @game = game
    @units = []
    @goblin_count = 0
    @elf_count = 0
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
    origin = [unit.i, unit.j]
    opponents = units.select { |u| u.class == unit.enemy }.reject(&:dead?)
    target_squares = opponents.flat_map { |u| reachable_empty_squares(u.coords) }
                              .sort

    return origin if target_squares.empty?

    seen = Set.new
    queue = [origin]
    goal = nil
    while queue.any?
      square = queue.shift

      seen << square

      next_squares = reachable_empty_squares(square).reject { |sq| seen.include?(sq) }
                                                    .sort

      goal = next_squares.find { |sq| target_squares.include?(sq) }
      break if goal

      queue.concat(next_squares)
    end

    # if no path leads to any of our targets, then no-op
    return origin if goal.nil?

    # great, we have our goal, now let's figure out the shortest path there
    reachable_empty_squares(origin).min_by do |sq|
      [distance(sq, goal), sq[0], sq[1]]
    end
  end

  def distance(start, finish)
    seen = Set.new
    queue = [[start, 0]]
    while queue.any?
      square, dist = queue.shift
      return dist if square == finish

      seen << square

      next_squares = reachable_empty_squares(square).reject { |sq| seen.include?(sq) }
                                                    .sort

      next_squares.each { |sq| queue << [sq, dist + 1] }
    end

    Float::INFINITY
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
  attr_accessor :i, :j, :hp
  def initialize(grid, i, j)
    @grid = grid
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
    3
  end

  def to_s
    'E'
  end
end
