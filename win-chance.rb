# encoding: utf-8
require './hangman-common.rb'

load_words

probabilities = {}

$words.each do |len, wds|
  alphabet = ('а' .. 'я').to_a
  words_tree = get_words_tree(wds, alphabet.dup)
  misses = {}
  rank_words(words_tree).group_by{ |w| w[:rank] }.each do |r, ws|
    misses[r] = (ws.size * 100.0 / wds.size).round
  end
  probabilities[len] = misses
end

# print table
probabilities.sort.each do |l, ms|
  print "%2d\s:" % l
  ms.sort.each do |mc, pb|
    print "\s(%d)\s%3.0f%" % [mc, ms.select { |x, p| x <= mc }
                                    .map    { |k, v| v }
                                    .reduce(:+)
                             ]
  end
  puts
end

