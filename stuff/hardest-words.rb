require './hangman-common.rb'

hangman = Hangman.new

hangman.load_words
hangman.sort_alphabet

ranked_words = []

hangman.words.each do |length, words|
  ranked_words.concat hangman.rank_words(hangman.get_words_tree(words))
end

ranked_words = ranked_words.group_by{ |w| w[:rank] }
max_rank = ranked_words.keys.max

puts ranked_words[max_rank]

