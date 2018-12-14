class Cart
  class ExplosionError < StandardError
  end
  UP = '^'.freeze
  DOWN = 'v'.freeze
  LEFT = '<'.freeze
  RIGHT = '>'.freeze
  SLASH = '/'.freeze
  BACKSLASH = '\\'.freeze
  INTERSECTION = '+'.freeze

  DIRS = [:left, :straight, :right]
  ORIENTATIONS = [UP, DOWN, LEFT, RIGHT]
  TURNS = [SLASH, BACKSLASH]
  DIFFS = {
    UP => [-1, 0],
    DOWN => [1, 0],
    LEFT => [0, -1],
    RIGHT => [0, 1],
  }
  TURN_CHANGES = {
    SLASH => {
      UP => RIGHT,
      DOWN => LEFT,
      RIGHT => UP,
      LEFT => DOWN,
    },
    BACKSLASH => {
      UP => LEFT,
      LEFT => UP,
      DOWN => RIGHT,
      RIGHT => DOWN,
    }
  }
  INTERSECTION_CHANGES = {
    UP => {
      left: LEFT,
      right: RIGHT,
      straight: UP,
    },
    DOWN => {
      left: RIGHT,
      right: LEFT,
      straight: DOWN,
    },
    LEFT => {
      left: DOWN,
      right: UP,
      straight: LEFT,
    },
    RIGHT => {
      left: UP,
      right: DOWN,
      straight: RIGHT,
    }
  }
  attr_reader :orientation, :underneath

  def initialize(orientation)
    raise unless ORIENTATIONS.include?(orientation)
    @orientation = orientation
    @intersection_count = 0
    @underneath = '.'
  end

  def next_square(x, y)
    dx, dy = DIFFS[@orientation]
    [x + dx, y + dy]
  end

  def move!(to)
    @underneath = to

    if to == ' ' || to.nil?
      raise "#{to} is not a valid location!"
    elsif ORIENTATIONS.include?(to)
      raise ExplosionError.new("whew!")
    elsif TURNS.include?(to)
      @orientation = TURN_CHANGES[to][@orientation]
    elsif to == INTERSECTION
      dir = DIRS[@intersection_count % DIRS.length]
      @orientation = INTERSECTION_CHANGES[@orientation][dir]
      @intersection_count += 1
    end
  end
end
