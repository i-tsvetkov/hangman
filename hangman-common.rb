# encoding: utf-8

class Hangman
  attr_reader :alphabet, :words

  def initialize(alphabet = ('а' .. 'я').to_a, words_file = 'words.txt')
    @alphabet   = alphabet.uniq
    @words_file = words_file
  end

  def get_letter_frequency(alphabet, words)
    return [] if words.empty?
    alphabet.map do |letter|
      { letter:    letter,
        frequency: words.count{ |w| w.include?(letter) }.quo(words.size)
      }
    end
  end

  def get_most_frequent_letter(alphabet, words)
    alphabet.max_by do |letter|
      words.count{ |w| w.include? letter }
    end
  end

  def get_pattern(letter, word, old_pattern)
    word.chars.zip(old_pattern.chars).map { |wch, pch|
      wch == letter ? wch : pch
    }.join
  end

  def get_letter_positions(letter, word)
    word.size.times.select{ |i| word[i] == letter }
  end

  def sort_alphabet
    @alphabet.reject! do |letter|
      @words.values.all? do |ws|
        ws.none?{ |w| w.include? letter }
      end
    end

    @alphabet.sort_by! do |letter|
      @words.values.map do |ws|
        ws.count{ |w| w.include?(letter) }
      end.reduce(&:+)
    end.reverse!
  end

  def solve(word, words = nil)
    guesses  = []
    pattern  = '_' * word.size
    alphabet = @alphabet.dup
    words ||= @words[word.size]
    words = words.dup

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

      return { guesses:guesses, words:[pattern] } unless pattern.include?('_')
      return { guesses:guesses, words:words } if words.size < 2
    end
  end

  def get_words_tree(words, alphabet = @alphabet)
    return { words:words } if alphabet.empty?
    return { words:words } if words.size == 1

    alphabet = alphabet.dup
    letter = get_most_frequent_letter(alphabet, words)
    alphabet.delete(letter)

    tree = words.group_by{ |w| get_letter_positions(letter, w) }

    tree.each do |pos, wds|
      tree[pos] = get_words_tree(wds, alphabet)
    end

    { letter:letter, tree:tree }
  end

  def find_word_in_tree(word, tree, letters = [])
    return { letters:letters, words: tree[:words] } if tree.key?(:words)
    return { letters:letters, words:[] } unless tree.key?(:tree)
    return { letters:letters, words:[word] } if (word.chars - letters).empty?

    letters.push(tree[:letter])
    pos = get_letter_positions(tree[:letter], word)

    t = tree[:tree][pos]
    return { letters:letters, words:[] } if t.nil?

    t.key?(:words) ? { letters:letters, words:t[:words] } : find_word_in_tree(word, t, letters)
  end

  def fast_solve(word, tree = nil)
    pattern = '_' * word.size
    result = find_word_in_tree(word, tree || @words[word.size])
    result[:letters].each do |l|
      pattern = get_pattern(l, word, pattern)
      puts "#{l}\s=>\s#{pattern}"
    end
    { guesses:result[:letters], words:result[:words] }
  end

  def load_words
    @words = File.readlines(@words_file)
    @words.each(&:strip!)
    @words = @words.group_by(&:size)
    nil
  end

  def load_words_tree
    load_words
    @words.each do |len, wds|
      @words[len] = get_words_tree(wds)
    end
    nil
  end

  def get_best_letter(pattern, guesses = [])
    return nil unless pattern.include?('_')

    words = @words[pattern.size].dup

    guesses.concat pattern.chars.select{ |c| c != '_' }

    char_group = guesses.empty? ? '.' : '[^' + guesses.join + ']'
    regex = Regexp.new(pattern.gsub('_', char_group))

    words.select!{ |w| w.match(regex) }

    alphabet = @alphabet - guesses
    get_most_frequent_letter(alphabet, words)
  end

  def rank_words(words_tree, rank = 0)
    return [{ words:words_tree[:words], rank:rank }] if words_tree.key?(:words)

    ranks = []
    words_tree[:tree].each do |pos, wds|
      ranks.concat (pos == []) ? rank_words(wds, rank + 1) : rank_words(wds, rank)
    end

    ranks
  end

  def statistical_solve(word, guesses = [], misses = [])
    pattern  = '_' * word.size
    words    = @words[word.size].dup
    alphabet = @alphabet - guesses - misses

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
      pairs.concat tree_to_key_value_pairs(v, new_path)
    end

    return pairs
  end

  def words_to_key_value_pairs(words, path, alphabet = @alphabet.dup)
    return [[path, { word: words.first }]] if words.size == 1

    letter = get_most_frequent_letter(alphabet, words)
    alphabet.delete(letter)

    pairs = [[path, { letter: letter }]]

    word_sets = words.group_by{ |w| get_letter_positions(letter, w) }

    word_sets.each do |pos, wds|
      new_path = [path, letter, pos].map(&:to_s).join('/')
      pairs.concat words_to_key_value_pairs(wds, new_path, alphabet.dup)
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
    file = open(filename, 'a')
    @words.each do |size, words|
      tree  = get_words_tree(words)
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
      return { guesses:guesses, words:[pattern] } unless pattern.include?('_')
    end
  end

  def get_all_matching_words(pattern)
    return pattern unless pattern.include?('_')

    letters = pattern.chars.select{ |c| c != '_' }
    return @words[pattern.size] if letters.empty?

    char_group = '[^' + letters.join + ']'
    regex = Regexp.new(pattern.gsub('_', char_group))
    @words[pattern.size].select{ |w| w.match(regex) }
  end
end

