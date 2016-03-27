# encoding: utf-8
require 'sqlite3'

def get_letter_frequency(alphabet, words)
  return [] if words.empty?
  alphabet.map do |letter|
    { letter:    letter,
      frequency: words.select{ |w| w.include?(letter) }.size.to_r / words.size
    }
  end
end

def get_most_frequent_letter(alphabet, words)
  lf = get_letter_frequency(alphabet, words)
  return nil if lf.empty?
  lf.max_by{ |l| l[:frequency] }[:letter]
end

def get_pattern(letter, word, old_pattern)
  new_pattern = word.chars.map{ |c| c == letter ? letter : '_' }.join
  new_pattern.chars.zip(old_pattern.chars).map{ |np, op| op == '_' ? np : op }.join
end

def get_letter_positions(letter, word)
  word.chars.each_with_index.map{ |c, i| c == letter ? i : nil }.compact
end

def solve(word, words = nil)
  guesses  = []
  pattern  = '_' * word.size
  alphabet = ('а' .. 'я').to_a
  words    = words || $words[word.size].dup

  return { guesses:[], words:[] } if words.nil?

  loop do
    letter = get_most_frequent_letter(alphabet, words)
    guesses.push(letter)
    alphabet.delete(letter)

    if word.include?(letter)
      pattern = get_pattern(letter, word, pattern)
      char_group = guesses.empty? ? '.' : '[^' + guesses.join + ']'
      regex = Regexp.new(pattern.gsub('_', char_group))
      words.select!{ |w| w.match(regex) }
    else
      words.reject!{ |w| w.include?(letter) }
    end

    puts "#{letter}\s=>\s#{pattern}"

    if words.size < 2
      return { guesses:guesses, words:words }
    end
  end

end

def get_words_tree(words, alphabet)
  return { words:words } if alphabet.empty?
  return { words:words } if words.size == 1

  letter = get_most_frequent_letter(alphabet, words)
  alphabet.delete(letter)

  tree = words.group_by{ |w| get_letter_positions(letter, w) }

  tree.each do |pos, wds|
    tree[pos] = get_words_tree(wds, alphabet.dup)
  end

  { letter:letter, tree:tree }
end

def find_word_in_tree(word, tree, letters = [])
  return { letters:letters, words: tree[:words] } if tree.key?(:words)
  return { letters:letters, words:[] } if not tree.key?(:tree)

  letters.push(tree[:letter])
  pos = get_letter_positions(tree[:letter], word)

  t = tree[:tree][pos]
  return { letters:letters, words:[] } if t.nil?

  t.key?(:words) ? { letters:letters, words:t[:words] } : find_word_in_tree(word, t, letters)
end

def fast_solve(word, tree = nil)
  pattern = '_' * word.size
  result = find_word_in_tree(word, tree || $words[word.size])
  result[:letters].each do |l|
    pattern = get_pattern(l, word, pattern)
    puts "#{l}\s=>\s#{pattern}"
  end
  { guesses:result[:letters], words:result[:words] }
end

def load_words
  if File.exist?("./words_cache.rb")
    $words = eval(File.read("./words_cache.rb"))
    return
  end
  words = File.open('./words.txt').each_line.map{ |w| w.strip.downcase.tr('А-Я', 'а-я') }.uniq
  $words = words.group_by(&:size)
end

def load_words_tree
  if File.exist?("./words_tree_cache.rb")
    $words = eval(File.read("./words_tree_cache.rb"))
    return
  end
  load_words()
  alphabet = ('а' .. 'я').to_a
  $words.each do |len, wds|
    $words[len] = get_words_tree(wds, alphabet)
  end
end

def get_best_letter(pattern, guesses = [])
  return nil if not pattern.include?('_')
  words = $words[pattern.size].dup
  guesses += pattern.chars.select{ |c| c != '_' }
  char_group = guesses.empty? ? '.' : '[^' + guesses.join + ']'
  regex = Regexp.new(pattern.gsub('_', char_group))
  words.select!{ |w| w.match(regex) }
  alphabet = ('а' .. 'я').to_a - guesses
  get_most_frequent_letter(alphabet, words)
end

def rank_words(words_tree, rank = 0)
  return [{ words:words_tree[:words], rank:rank }] if words_tree.key?(:words)

  ranks = []
  words_tree[:tree].each do |pos, wds|
    ranks += (pos == []) ? rank_words(wds, rank + 1) : rank_words(wds, rank)
  end

  ranks
end

def statistical_solve(word, guesses = [], misses = [])
  pattern  = '_' * word.size
  words    = $words[word.size].dup
  alphabet = ('а' .. 'я').to_a - guesses - misses

  (guesses - misses).each do |letter|
    words.select!{ |w| w.include?(letter) }
    pattern = get_pattern(letter, word, pattern)
  end

  misses.each do |letter|
    words.reject!{ |w| w.include?(letter) }
  end

  loop do
    best_letter = get_most_frequent_letter(alphabet, words)
    break if best_letter.nil?

    if word.include?(best_letter)
      words.select!{ |w| w.include?(best_letter) }
      pattern = get_pattern(best_letter, word, pattern)
    else
      words.reject!{ |w| w.include?(best_letter) }
    end

    guesses.push(best_letter)
    alphabet.delete(best_letter)

    puts "#{best_letter}\s=>\s#{pattern}"

    break unless pattern.include?('_')
  end

  return { pattern:pattern, guesses:guesses }
end

def tree_to_key_value_pairs(tree, path)
  return [[path, { word: tree[:words].first }]] if tree.key?(:words)
  pairs = [[path, { letter: tree[:letter] }]]
  tree[:tree].each do |k, v|
    new_path = [path, tree[:letter], k].map(&:to_s).join('/')
    pairs += tree_to_key_value_pairs(v, new_path)
  end
  return pairs
end

def get_sql_commands(pairs)
  pairs.map do |k, v|
    "INSERT INTO HANGMAN VALUES ('#{k}', '#{v}');"
  end.join("\n").concat("\n\n")
end

def write_sql_file(filename)
  load_words
  alphabet = ('а' .. 'я').to_a
  file = open(filename, 'a')
  $words.each do |size, words|
    tree  = get_words_tree(words, alphabet.dup)
    pairs = tree_to_key_value_pairs(tree, "/#{size}")
    file.write(get_sql_commands(pairs))
  end
  file.close
end

def db_solve(word)
  db = SQLite3::Database.new('hangman.db')
  path = "/#{word.size}"

  pattern = '_' * word.size
  guesses = []

  loop do
    result = db.execute("SELECT DATA FROM HANGMAN WHERE PATH = '#{path}'")
    return { guesses: guesses, words: [] } if result.empty?

    result = eval(result.first.first) # JSON is better but eval is evil

    return { guesses: guesses, words: [result[:word]] } if result.key?(:word)

    letter = result[:letter]
    guesses.push(letter)
    path.concat("/#{letter}/#{get_letter_positions(letter, word)}")

    pattern = get_pattern(letter, word, pattern)
    puts "#{letter}\s=>\s#{pattern}"
  end
end

