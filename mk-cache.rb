require './hangman-common.rb'

load_words_tree

File.write("./words_tree_cache.rb", $words.to_s)

load_words

File.write("./words_cache.rb", $words.to_s)

