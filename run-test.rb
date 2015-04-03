require 'benchmark'
require './hangman-common.rb'

class FakeStdOut
  def write(s)
  end
end

def silent_block(&block)
  orig_stdout, $stdout = $stdout, FakeStdOut.new
  yield
  $stdout = orig_stdout
  nil
end

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
              silent_block do
                test_words.each do |w|
                  test_ok &&= solve(w)[:words][0] == w
                end
              end
            end
puts "time:\s#{real_time}"
puts "avrg:\s#{real_time/test_words.size}"
puts "TEST:\s#{test_ok ? green 'passed' : red 'failed'}"

puts "Testing fast_solve():"
load_words_tree

test_ok = true
real_time = Benchmark.realtime do
              silent_block do
                test_words.each do |w|
                  test_ok &&= fast_solve(w)[:words][0] == w
                end
              end
            end
puts "time:\s#{real_time}"
puts "avrg:\s#{real_time/test_words.size}"
puts "TEST:\s#{test_ok ? green 'passed' : red 'failed'}"

