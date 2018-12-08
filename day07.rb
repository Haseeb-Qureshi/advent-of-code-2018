require 'set'
require 'pp'
# Part 1
puts "Part 1"

# Topological sort, bro
# Step H must be finished before step G can begin.

INPUT = File.readlines('input07.txt').map(&:chomp)

ALL_LETTERS = Set.new
nodes = Hash.new { |h, k| h[k] = [] }

INPUT.each do |line|
  from, to = line.scan(/step (.)/i).flatten
  ALL_LETTERS << to << from
  nodes[from] << to
end

def topological_sort(out_edges)
  in_edges = Hash.new { |h, k| h[k] = [] }
  in_edges_count = Hash.new(0)
  ALL_LETTERS.each do |from|
    out_edges[from].each do |to|
      in_edges[to] << from
      in_edges_count[to] += 1
    end
  end

  zero_dependencies = ALL_LETTERS.select { |from| in_edges_count[from] == 0 }
  ordering = []

  until ordering.length == ALL_LETTERS.length
    next_val = zero_dependencies.delete(zero_dependencies.min)
    ordering << next_val
    out_edges[next_val].each do |to|
      in_edges_count[to] -= 1
      zero_dependencies << to if in_edges_count[to] == 0
    end
  end

  ordering
end

output = topological_sort(nodes).join
puts output

# Part 2
puts "Part 2"

def elf_time(out_edges, extra_seconds = 60, worker_limit = 5)
  in_edges = Hash.new { |h, k| h[k] = [] }
  in_edges_count = Hash.new(0)
  ALL_LETTERS.each do |from|
    out_edges[from].each do |to|
      in_edges[to] << from
      in_edges_count[to] += 1
    end
  end

  ready = ALL_LETTERS.select { |from| in_edges_count[from] == 0 }
  workers = []
  finished = 0
  seconds = 0

  until finished == ALL_LETTERS.length
    until ready.empty? || workers.length == worker_limit
      ready_node = ready.pop
      workers << [extra_seconds + ready_node.ord - ('A'.ord - 1), ready_node]
    end

    p [workers, ready.count]

    seconds_passed = workers.min_by(&:first).first
    seconds += seconds_passed
    workers.map! { |seconds, char| [seconds - seconds_passed, char] }
    done_workers, workers = workers.partition { |seconds, node| seconds == 0 }

    puts "Done workers: #{done_workers}"
    puts "Workers: #{workers}"

    done_workers.map(&:last).each do |next_val|
      p "Processing #{next_val}"
      finished += 1

      out_edges[next_val].each do |to|
        in_edges_count[to] -= 1
        ready << to if in_edges_count[to] == 0
      end
    end
  end

  require 'pry'
  binding.pry
  seconds
end

puts elf_time(nodes)
