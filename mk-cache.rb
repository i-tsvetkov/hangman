require 'json'
require './hangman-common.rb'

load_words_tree

File.write("./words_tree_cache.json", JSON.generate($words))

load_words

File.write("./words_cache.json", JSON.generate($words))

