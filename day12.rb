# Part 1
puts "Part 1"

INPUT = File.readlines('input12.txt').map(&:chomp).reject(&:empty?)

initial_state = INPUT.first.split.last.prepend('...')
state_transitions = INPUT.drop(1).map do |s|
  k, _, v = s.split
  [k, v]
end.to_h

def transition_state(current_state, transitions)
  current_state.length.times.map do |i|
    if i < 2
      slice = current_state[0..i + 2].rjust(5, '.')
    elsif i > current_state.length - 3
      slice = current_state[i - 2..-1].ljust(5, '.')
    else
      slice = current_state[i - 2..i + 2]
    end

    transitions[slice] || '.'
  end.join
end

def compute_score(state)
  state.length.times.reduce(0) do |sum, i|
    sum + (state[i] == '.' ? 0 : i - 3)
  end
end

state = initial_state + '.' * 20

20.times do |i|
  state = transition_state(state, state_transitions)
end

puts compute_score(state)

# Part 2
puts "Part 2"
scores = []
state = initial_state + '.' * 150
150.times do |i|
  state = transition_state(state, state_transitions)
  score = compute_score(state)
  prev_score = scores.any? ? scores[-1][1] : 0
  scores << [i + 1, score, score - prev_score]
end

# Finding: 150 = 8845, every increment goes up by 51
# 8845 + (x - 150) * 51 = y
# 8845 + (50_000_000_000 - 150) * 51 = y
puts 8845 + (50_000_000_000 - 150) * 51
