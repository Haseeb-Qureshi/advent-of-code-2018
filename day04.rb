# Strategy 1: Find the guard that has the most minutes asleep. What minute does that guard spend asleep the most?
# Part 1
require 'pry'
require 'time'
puts "Part 1"

input = File.readlines('input04.txt').map(&:chomp)
times = input.map do |line|
  [Time.parse(line[/\[(.+)\]/]), line.split("] ").last]
end.sort_by(&:first)

seconds_asleep = Hash.new(0)
t0, guard = nil, nil

times.each do |time, action|
  if action.start_with?("Guard #")
    guard = action[/\d+/].to_i
  elsif action == "falls asleep"
    t0 = time
  elsif action == "wakes up"
    seconds_asleep[guard] += time - t0
  else
    raise "wtf"
  end
end

guard_with_most_sleep = seconds_asleep.sort_by(&:last).last.first

guard = nil
minutes = [0] * 60
times.each do |time, action|
  if action.start_with?("Guard #")
    guard = action[/\d+/].to_i
  end

  if guard != guard_with_most_sleep
    guard = nil
    next
  end

  if action == "falls asleep"
    t0 = time
  elsif action == "wakes up"
    until t0 == time
      minutes[t0.min] += 1
      t0 += 60
    end
  end
end
p (minutes.each_with_index.max_by(&:first).last) * guard_with_most_sleep


# Part 2
puts "Part 2"

guard_minutes = Hash.new { |h, k| h[k] = [0] * 60 }
guard = nil

times.each do |time, action|
  if action.start_with?("Guard #")
    guard = action[/\d+/].to_i
  elsif action == "falls asleep"
    t0 = time
  elsif action == "wakes up"
    until t0 == time
      guard_minutes[guard][t0.min] += 1
      t0 += 60
    end
  end
end

puts guard_minutes.map { |guard, minutes| [guard, minutes.each_with_index.max_by(&:first)] }
                  .sort_by { |guard, (count, best_minute)| count }
                  .map { |guard, (count, best_minute)| guard * best_minute }
                  .last
