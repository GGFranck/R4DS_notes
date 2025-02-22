library(tidyverse)
library(babynames)
library(stringr)
library(reprex)
# 模式基础-------
str_view(fruit, "berry")
grep("berry", fruit)

str_view(fruit, "a...e")

str_view(fruit, "an?")
str_view(fruit, "ap+")
str_view(fruit, "ap*")
str_view(c("awowowp"), "a*p")

str_view(words, "[aeiou]x[aeiou]")
str_view(words, "[^aeiou]y[^aeiou]")

str_view(c("1234", "1331"), "[3-5]3")
str_view(fruit, "[a-u]n")

str_view(fruit, "apple|melon|nut")
str_view(fruit, "aa|ee|ii|oo|uu")

# 关键函数-----
str_detect(c("a", "b", "c"), "a")
grepl("a", c("a", "b", "c"))

babynames %>%
  filter(str_detect(name, "x")) %>%
  count(name, wt = n, sort = TRUE)

babynames %>%
  group_by(year) %>%
  summarise(prop_x = mean(str_detect(name, "x"))) %>%
  ggplot(aes(year, prop_x)) +
  geom_line()

babynames %>%
  group_by(year) %>%
  summarise(prop_x = sum(str_detect(name, "x") * n) / sum(n)) %>%
  ggplot(aes(year, prop_x)) +
  geom_line()

str_subset(fruit, "^a|^b")
fruit[grep("^a|^b", fruit)]
str_which(fruit, "^a|^b")
grep("^a|^b", fruit)

str_count(fruit, "[aeiou]")
str_count("abababa", "aba")
str_view("abababa", "aba")
babynames %>%
  count(name) %>%
  mutate(
    vowels = str_count(name, "[aeiou]"),
    consonants = str_count(name, "[^aeiou]")
  )
babynames %>%
  count(name) %>%
  mutate(
    vowels = str_count(name, "[aeiouAEIOU]"),
    consonants = str_count(name, "[^aeiouAEIOU]")
  )
babynames %>%
  count(name) %>%
  mutate(
    vowels = str_count(name, regex("[aeiou]", ignore_case = TRUE)),
    consonants = str_count(name, "[^aeiouAEIOU]"),
    consonants2 = str_count(str_to_lower(name), "[^aeiou]")
  )

reprex({
  library(stringr)
  x <- c("apple", "banana", "pear")
  str_replace(x, "[aeiou]", "-")
  str_replace_all(x, "[aeiou]", "-")
  str_remove(x, "[aeiou]")
  str_remove_all(x, "[aeiou]")
})

df <- tribble(
  ~str,
  "<Sheryl>-F_34",
  "<Kisha>-F_45",
  "<Brandon>-N_33",
  "<Sharon>-F_38",
  "<Penny>-F_58",
  "<Justin>-M_41",
  "<Patricia>-F_84",
)
df %>%
  separate_wider_regex(
    str,
    patterns = c(
      "<",
      name = "[A-Za-z]+",
      ">-",
      gender = ".",
      "_",
      age = "[0-9]+"
    )
  )
## 练习
babynames %>%
  mutate(
    vowels_num = str_count(str_to_lower(name), "[aeiou]"),
    vowels_prop = vowels_num / str_length(name)
  ) %>%
  arrange(desc(vowels_num))
babynames %>%
  mutate(
    vowels_num = str_count(str_to_lower(name), "[aeiou]"),
    vowels_prop = vowels_num / str_length(name)
  ) %>%
  arrange(desc(vowels_prop))

# Replace all forward slashes in "a/b/c/d/e" with backslashes.
reprex({
  library(stringr)
  a <- "a/b/c/d/e"
  str_replace_all(a, "/", "\\")
  gsub("/", "\\\\", a)
})
a <- "a/b/c/d/e"
str_replace_all(a, "/", "\\")
gsub("/", "\\\\", a)

# 大写改小写，只能用str_replace_all()
babynames$name %>%
  head() %>%
  str_replace_all("[:upper:]", tolower)
babynames$name %>%
  head() %>%
  str_replace_all("[A-Z]", tolower)

set.seed(1234)
a <- runif(11 * 5, min = 0, max = 9) %>%
  round() %>%
  matrix(ncol = 11) %>%
  apply(1, paste, collapse = "")
a <- c(a, seq(5, 20, 4), sample(letters, 7))
str_view(a, "^[0-9]{11}$")

# 模式 细节 进阶-------
str_view(".")
# str_view("\.")
str_view("\\.")
str_view(c("abc", "a.c", "bef"), "a.c")
str_view(c("abc", "a.c", "bef"), "a\\.c")

str_view("a\\b")
str_view("a\\b", "\\\\")
str_view("a\\b", r"(\\)")
str_view(c("abc", "a.c", "a*c", "a c"), "a[.]?c")
str_view(c("abc", "a.c", "a*c", "a c"), "a[*]?c")
str_view(c("abc", "a.c", "a*c", "a c"), "a[ ]?c")

str_view(fruit, "^a")
str_view(fruit, "a$")
str_view(fruit, "apple")
str_view(fruit, "^apple$")

x <- c("summary(x)", "summarize(df)", "rowsum(x)", "sum(x)")
str_view(x, "sum")
str_view(x, "\\bsum\\b")

str_view("abc", c("^", "$", "\\b"))
str_detect("abc", c("^", "$", "\\b"))
str_replace_all("abc", c("^", "$", "\\b"), "--")

str_view("a^b/c.d", "[.]")
str_view("a^b/c.d", "[^]")
str_view("a^b/c.d", "[\\^]")
reprex({
  library(stringr)
  x <- "abcd ABCD 12345 -!@#%."
  str_view(x, "[abc]")
  str_view(x, "[abc]+")
  str_view(x, "[a-z]+")
  str_view(x, "[^a-z0-9]+")
  # 字符类的也有反义的要求
  str_view("a-b-c", "[a-c]")
  str_view("a-b-c", "[a\\-c]")
  str_view("a-b-c", "a-b")
})

x <- "abcd ABCD 12345 -!@#%."
str_view(x, "\\d+")
str_view(x, "\\D+")
str_view(x, "\\s+")
str_view(x, "\\S+")
str_view(x, "\\w+")
str_view(x, "\\W+")
# 仅字母
str_view(x, "[[:alpha:]]+")

x <- str_flatten(c(rep("1", 4), rep("2", 5), rep("3", 3)))
str_view(x, "1{2}")
str_view(x, "2{4,}")
str_view(x, "\\d{3,5}")

str_view("a|b", "^[ab]")

str_view(fruit, "(..)\\1")
str_view(words, "^(..).*\\1$")

sentences %>%
  str_view() %>%
  head(5)
sentences %>%
  str_replace("(\\w+) (\\w+) (\\w+)", "\\1 \\3 \\2") %>%
  str_view() %>%
  head(5)

str_view("apple pie", "p(.)")
str_match("apple pie", "p(.)")
sentences %>%
  str_match("the (\\w+) (\\w+)") %>%
  head()
sentences %>%
  str_match("the (\\w+) (\\w+)") %>%
  as_tibble() %>%
  set_names("match", "word1", "word2")

x <- c("a gray cat", "a grey dog")
str_match(x, "gr(e|a)y")
str_match(x, "gr(?:e|a)y")

## 练习
x <- c("\"\'\\", "\"$^$\"")
str_view(x)
str_view(x, r"("'\\)")
str_view(x, r"("\$\^\$")")
str_view(x, "\"\\$\\^\\$\"")

str_view(words, "^y")
str_view(words, "^[^y]")
str_view(words, "x$")
str_view(words, "^\\w{3}$")
words[str_length(words) == 3]
str_view(words, "\\w{7,}")
str_view(words, "[aeiou][^aeiou]")
str_view(words, "([aeiou][^aeiou]).*\\1")
str_view(words, "([aeiou][^aeiou])\\1")

x <- "airplane/aeroplane, aluminum/aluminium, analog/analogue, ass/arse, center/centre, defense/defence, donut/doughnut, gray/grey, modeling/modelling, skeptic/sceptic, summarize/summarise"
str_view(x, "(air|aero)plane")
str_view(x, "alumini?um")
str_view(x, "analog(ue)?")
str_view(x, "a.?s[se]")
str_view(x, "cent[er]+")
str_view(x, "defen.e")
str_view(x, "do.*nut")
str_view(x, "gr(a|e)y")
str_view(x, "modell?ing")
str_view(x, "s.eptic")
str_view(x, "summari.e")

str_replace(words, "(^.)(.*)(.$)", "\\3\\2\\1") %>% head()
words %>% head()

x <- c("", "1234", "abcd", "{}", "{hah}", "1234-12-21ah", "\\\\\\\\", ".a.a.a.a.a", "aaaa")
str_view(x, "^.*$")
str_view(x, "\\{.+\\}")
str_view(x, "\\d{4}-\\d{2}-\\d{2}")
str_view(x, "\\\\{4}")
str_view(x, "\\..\\..\\..")
str_view(x, "(.)\\1\\1")
str_view(x, "(..)\\1")

# 模式控制-----
bananas <- c("banana", "Banana", "BANANA")
str_view(bananas, "banana")
str_view(bananas, regex("banana", ignore_case = TRUE))

reprex({
  library(stringr)
  x <- "Line 1\nLine 2\nLine 3"
  str_view(x, "Line")
  str_view(x, ".Line")
  str_view(x, regex(".Line", dotall = TRUE))
})
x <- "Line 1\nLine 2\nLine 3"
str_view(x, "Line")
str_view(x, ".Line")
str_view(x, regex(".Line", dotall = TRUE))

str_view(x, "^Line")
str_view(x, regex("^Line", multiline = TRUE))

str_view(c("", "a", "."), fixed("."))
str_view("x X", fixed("X", ignore_case = TRUE))

str_view(sentences, "^The")
str_view(sentences, "^The\\b")
str_view(sentences, "^She|He|It|They\\b")

str_view(words, "^[^aeiou]+$")
str_view(words[!str_detect(words, "[aeiou]")])

str_view(words, "a.*b|b.*a")
words[str_detect(words, "a") & str_detect(words, "b")]

str_view(sentences, "\\b(red|green|blue)\\b")

rgb <- c("red", "green", "blue")
str_c("\\b(", str_flatten(rgb, "|"), ")\\b")
str_view(colors())
str_view(colors(), "\\d") # 含数字的
cols <- colors()
cols <- cols[!str_detect(cols, "\\d")]
str_view(cols)
pattern <- str_c("\\b(", str_flatten(cols, "|"), ")\\b")
str_view(sentences, pattern)

str_detect(c("a", "."), ".")
str_detect(c("a", "."), str_escape("."))
str_detect(c("a", "."), fixed("."))

# 练习----
str_view(words, "^x|x$")
words[str_detect(words, "^x") | str_detect(words, "x$")]
str_view(words, "^[aeiou].*[^aeiou]$")
words[str_detect(words, "^[aeiou]") & str_detect(words, "[^aeiou]$")]
# 不会
words[
  str_detect(words, "a") &
    str_detect(words, "e") &
    str_detect(words, "i") &
    str_detect(words, "o") &
    str_detect(words, "u")
]

str_detect(c("awiwe", "wciwe"), "[^c]i.*e")

datalist <- data(package = "datasets")$results[, "Item"]
datalist[!str_detect(datalist, "\\(")]

# 其他-----
?separate_longer_delim()
apropos("geom")
getwd()
list.files(path = getwd(), "txt")

vignette("regular-expressions", package = "stringr")
