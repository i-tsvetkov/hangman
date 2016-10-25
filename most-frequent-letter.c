#include <string.h>
#include <stdio.h>

char get_most_frequent_letter(const char *alphabet, size_t alphabet_len,
                              const char   **words, size_t words_len)
{
  char fst_most_freq = '\0';
  char snd_most_freq = '\0';

  int fst_most_freq_num = 0;
  int snd_most_freq_num = 0;

  int letters_amount[alphabet_len];

  for (int i = 0; i < alphabet_len; ++i)
    letters_amount[i] = 0;

  for (int i = 0, left_words = words_len - 1; i < words_len; ++i, --left_words)
    for (int j = 0; j < alphabet_len; ++j)
      if (strchr(words[i], alphabet[j]) != NULL)
      {
        letters_amount[j] += 1;

        if (letters_amount[j] > fst_most_freq_num)
        {
          if (alphabet[j] != fst_most_freq)
          {
            snd_most_freq     = fst_most_freq;
            snd_most_freq_num = fst_most_freq_num;
          }

          fst_most_freq     = alphabet[j];
          fst_most_freq_num = letters_amount[j];
        }
        else if (letters_amount[j] > snd_most_freq_num)
        {
          snd_most_freq     = alphabet[j];
          snd_most_freq_num = letters_amount[j];
        }

        if (fst_most_freq_num > snd_most_freq_num + left_words)
        {
          printf("fst_most_freq     = %c\n",   fst_most_freq);
          printf("fst_most_freq_num = %d\n\n", fst_most_freq_num);

          printf("snd_most_freq     = %c\n",   snd_most_freq);
          printf("snd_most_freq_num = %d\n\n", snd_most_freq_num);

          printf("left_words        = %d\n",   left_words);
          printf("words_len         = %d\n\n", words_len);

          return fst_most_freq;
        }
      }

  return fst_most_freq;
}


char simple_get_most_frequent_letter(const char *alphabet, size_t alphabet_len,
                                     const char   **words, size_t words_len)
{
  int letters_amount[alphabet_len];

  for (int i = 0; i < alphabet_len; ++i)
    letters_amount[i] = 0;

  for (int i = 0; i < words_len; ++i)
    for (int j = 0; j < alphabet_len; ++j)
      if (strchr(words[i], alphabet[j]) != NULL)
        letters_amount[j] += 1;

  int max_index = 0;

  for (int i = 0; i < alphabet_len; ++i)
    if (letters_amount[i] > letters_amount[max_index])
      max_index = i;

  return alphabet[max_index];
}

int main(int argc, char **argv)
{
  if (argc < 2)
  {
    printf("No words given!\n");
    return 1;
  }

  const char **words  = (const char**) argv + 1;
  const int words_len = argc - 1;

  const char alphabet[] = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i',
                           'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r',
                           's', 't', 'u', 'v', 'w', 'x', 'y', 'z'};

  const int alphabet_len = strlen(alphabet);

  char most_frequent_letter = get_most_frequent_letter(alphabet, alphabet_len,
                                                          words, words_len);

  printf("most_frequent_letter = %c\n\n", most_frequent_letter);
}

