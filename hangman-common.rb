# encoding: utf-8

def get_letter_frequency(alphabet, words)
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
  word.chars.with_index.map{ |c, i| c == letter ? i : nil }.compact
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
  words = File.open('./words.txt').lines.map{ |w| w.strip.downcase.tr('А-Я', 'а-я') }.uniq
  $words = words.group_by{ |w| w.size }
end

def load_words_tree
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

