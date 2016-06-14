require './hangman-common.rb'

hangman = Hangman.new

hangman.load_words
hangman.sort_alphabet

ranks = Hash.new(0)

hangman.words.each do |length, words|
  hangman.rank_words(hangman.get_words_tree(words))
  .group_by{ |w| w[:rank] }.each do |rank, ws|
    ranks[rank] += ws.size
  end
end

words_cnt = hangman.words.values.map(&:size).reduce(&:+)

puts "Позволени грешки|Процент на успех|Брой на решени думи"
puts "---|---|---"

ranks.keys.sort.each do |rank|
  cnt = ranks.select{ |r, _| r <= rank }.values.reduce(&:+)
  puts "#{rank}|#{(100.0 * cnt / words_cnt).round(2)}%|#{cnt}"
end

