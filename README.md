# Hangman - алгоритми за решаване на Бесеница

### Как се използва?
Има три имплементации `solve`, `fast_solve` и `db_solve`.
* `solve` - стандартна имплементация на алгоритъма
   използваща регулярни изрази.
* `fast_solve` - използва доста повече RAM памет (> 2 GB),
   но пък е доста по-бърза в намирането на решение.
   Имплементацията използва дърво, което се генерира
   от алгоритъма за намиране на решение.
* `db_solve` - имплементация основана на идеята на `fast_solve`,
   но използваща база данни за съхранение на репрезентация на дървото,
   има скоростта на `fast_solve`,
   но няма нужда от почти никаква RAM памет.

**Примери**:
```ruby
require './hangman-common.rb'

hangman = Hangman.new

# зареждането може да отнеме 5-15 минути
hangman.load_words

hangman.solve('кактус')
```
```ruby
require './hangman-common.rb'

hangman = Hangman.new

# зареждането може да отнеме 15-30 минути и между 2-4 GB RAM памет.
hangman.load_words_tree

hangman.fast_solve('кактус')
```
```ruby
# не забравяйте да разархивирате hangman.db.lzma
require './hangman-db-ai.rb'

hangman = Hangman.new

hangman.db_solve('кактус')
```

### Описание на алгоритъма за намиране на решение
Алгоритъма започва със списък с (един милион) думи *предполагайки*, че търсената дума се намира в него.  
Списъкът се редуцира до тези думи, които имат дължината на търсената дума.

1. Стъпка - Намираме буквата, която се съдържа в най-много думи
   и не е никоя от тези, които вече сме опитали.
2. Стъпка - Проверяваме дали буквата се съдържа в търсената дума.
  * Ако се съдържа и няма други букви за отгатване, значи алгоритъма е отгатнал думата.
  * Ако се съдържа и има други букви за отгатване редуцираме множеството от думи, до тези които съдържат
   тази буква на същите позиции, на които тя се среща в търсената дума.
  * Ако не се съдържа редуцираме множеството от думи, до тези които не съдържат тази буква.
3. Стъпка - Проверяваме дали множеството от думи е празно или съдържа само една дума.
  * Ако съдържа само една дума, значи тя *би трябвало* да е решение.
  * Ако множеството е празно, значи алгоритъма не е открил решение.
  * Ако множеството съдържа повече от една дума отиваме на **Стъпка 1**.

