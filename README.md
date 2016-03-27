# Hangman - алгоритми за решаване на Бесеница

### Как се използва?
Има три имплементации `solve`, `fast_solve` и `db_solve`.
* `solve (hangman-ai.rb)` - стандартна имплементация на алгоритъма
   използваща регулярни изрази.
* `fast_solve (hangman-fast-ai.rb)` - използва доста повече RAM памет (> 2 GB),
   но пък е доста по-бърза в намирането на решение.
  `hangman-fast-ai.rb` използва дърво, което се генерира
   от алгоритъма за намиране на решение.
* `db_solve (hangman-common.rb)` - имплементация основана на идеята на `hangman-fast-ai.rb`,
   но използваща база данни за съхранение на репрезентация на дървото, има скороста на `hangman-fast-ai.rb`,
   но няма нужда от почти никаква RAM памет.

Зареждането на файловете може да отнеме време, понеже имплементациите
залагат доста на преизчисления, с цел оптимизация на скоростта.

Може да намалите използваната RAM памет от `hangman-fast-ai.rb`,
като намалите броя на думите в `words.txt` текущо са около един милион.

**Примери**:
```ruby
# зареждането може да отнеме 5-15 минути
require './hangman-ai.rb'

solve('кактус')
```
```ruby
# зареждането може да отнеме 15-30 минути и между 2-4 GB RAM памет.
require './hangman-fast-ai.rb'

fast_solve('кактус')
```
```ruby
require './hangman-common.rb'

db_solve('кактус')
```

### Описание на алгоритъма за решаване
Алгоритъма започва със списък с думи предполагайки,
че търсената дума се намира в него.  
Списъкът се редуцира до тези думи, които имат дължината на търсената дума.

1. Стъпка - намираме буквата, която се съдържа в най-много думи
   и не е никоя от тези, които вече сме опитали.
2. Стъпка - проверяваме дали буквата се съдържа в търсената дума.
  * Ако се съдържа редуцираме множеството от думи,
    до тези които съдържат тази буква
    на същите позиции, на които тя се среща в търсената дума.
  * Ако не се съдържа редуцираме множеството от думи,
    до тези които не съдържат тази буква.
3. Стъпка - Проверяваме дали множеството от думи е празно
или съдържа само една дума.
  * Ако съдържа само една дума, значи тя *би трябвало* да е решение.
  * Ако множеството е празно, значи алгоритъма не е открил решение.
  * Ако множеството съдържа повече от една дума отиваме на **стъпка 1**.

Колкото по-голям е списъка, толкова е по-голям шанса
търсената дума да е в него.  
Използвания списък е почти един милион думи.

Обобщено:  
**Стъпка 1** - намира буквата, която е най-вероятно да бъде в търсената дума.  
**Стъпка 2** - или правилно отгатваме тази буква,
               или намаляваме множеството за търсене
               с максималния възможен размер.  
**Стъпка 3** - проверява дали трябва да спрем.  

