require 'benchmark'
require './hangman-common.rb'

def red(s)
  "\e[1;31m" + s + "\e[m"
end

def green(s)
  "\e[1;32m" + s + "\e[m"
end

test_words = File.read("./test_words.txt").lines.map(&:strip)

puts "Testing solve():"
load_words

test_ok = true
real_time = Benchmark.realtime do
              test_words.each do |w|
                test_ok &&= solve(w)[:words][0] == w
              end
            end
puts "time:\s#{real_time}"
puts "avrg:\s#{real_time/test_words.size}"
puts "TEST:\s#{test_ok ? green 'passed' : red 'failed'}"

puts "Testing fast_solve():"
load_words_tree

test_ok = true
real_time = Benchmark.realtime do
              test_words.each do |w|
                test_ok &&= fast_solve(w)[:words][0] == w
              end
            end
puts "time:\s#{real_time}"
puts "avrg:\s#{real_time/test_words.size}"
puts "TEST:\s#{test_ok ? green 'passed' : red 'failed'}"

