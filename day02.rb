# To make sure you didn't miss any, you scan the likely candidate boxes again, counting the number that have an ID containing exactly two of any letter and then separately counting those with exactly three of any letter. You can multiply those two counts together to get a rudimentary checksum and compare it to what your device predicts.
#
# For example, if you see the following box IDs:
#
# abcdef contains no letters that appear exactly two or three times.
# bababc contains two a and three b, so it counts for both.
# abbcde contains two b, but no letter appears exactly three times.
# abcccd contains three c, but no letter appears exactly two times.
# aabcdd contains two a and two d, but it only counts once.
# abcdee contains two e.
# ababab contains three a and three b, but it only counts once.
# Of these box IDs, four of them contain a letter which appears exactly twice, and three of them contain a letter which appears exactly three times. Multiplying these together produces a checksum of 4 * 3 = 12.
#
# What is the checksum for your list of box IDs?

def letter_counts(s)
  s.chars.group_by { |c| c }.map { |k, v| [k, v.length] }.to_h
end

# Part 1
puts "Part 1"
INPUT = File.readlines("input02.txt").map(&:chomp)
twices = 0
thrices = 0

INPUT.each do |s|
  has_a_twice = false
  has_a_thrice = false
  letter_counts(s).each do |c, count|
    has_a_twice = true if count == 2
    has_a_thrice = true if count == 3
  end

  twices += 1 if has_a_twice
  thrices += 1 if has_a_thrice
end

puts twices * thrices

# Part 2
puts "Part 2"

def differences(s1, s2)
  [s1, s2].max_by(&:length).chars.each_index.count do |i|
    s1[i] != s2[i]
  end
end

s1, s2 = INPUT.combination(2).find do |s1, s2|
  differences(s1,s2) == 1
end

puts s1.chars.select.with_index { |c, i| c == s2[i] }.join







#
