NUM_OF_WORDS = 100

words = File.read("./words.txt").lines.map{ |w| w.strip.downcase.tr('А-Я', 'а-я') }.uniq
test_words = words.sample(NUM_OF_WORDS)
File.write("./test_words.txt", test_words.join("\n"))

