library(tidyverse)
library(babynames)
library(stringr)

# 生成字符串------
string1 <- "This is a string"
string2 <- 'If I want to include a "quote" inside a string, I use single quotes'
# 转义
double_quote <- "\"" # or '"'
single_quote <- "'" # or "'"
backslash <- "\\"
x <- c(single_quote, double_quote, backslash)
x
str_view(x)
writeLines(x)

tricky <- "double_quote <- \"\\\"\" # or '\"'
single_quote <- '\\'' # or \"'\""
str_view(tricky)
#> [1] │ double_quote <- "\"" # or '"'
#>     │ single_quote <- '\'' # or "'"

tricky <- r"(double_quote <- "\"" # or '"'
single_quote <- '\'' # or "'")"
str_view(tricky)
#> [1] │ double_quote <- "\"" # or '"'
#>     │ single_quote <- '\'' # or "'"

x <- c("one\ntwo", "one\ttwo", "\u00b5", "\U0001f604")
x
#> [1] "one\ntwo" "one\ttwo" "µ"        "😄"
str_view(x)
#> [1] │ one
#>     │ two
#> [2] │ one{\t}two
#> [3] │ µ
#> [4] │ 😄

## 练习
a <- r"(He said "That's amazing!")"
b <- r"(\a\b\c\d)"
c <- r"(\\\\\\)"
writeLines(c(a, b, c))
reprex::reprex({
  library(stringr)
  "\u00a0"
  str_view("\u00a0")
  x <- "This\u00a0is\u00a0tricky"
  x
})

# 生成多个字符串-----
str_c("x", "y")
#> [1] "xy"
str_c("x", "y", "z")
#> [1] "xyz"
str_c("Hello ", c("John", "Susan"))
#> [1] "Hello John"  "Hello Susan"
str_c("Hello ", c("John", "Susan", "West"), "!", c("1", "2", "3"))

paste0("Hello ", c("John", "Susan", "West"), "!", c("1", "2", "3"))

df <- tibble(name = c("Flora", "David", "Terra", NA))
df |> mutate(greeting = str_c("Hi ", name, "!"))

df |>
  mutate(
    greeting1 = str_c("Hi ", coalesce(name, "you"), "!"),
    greeting2 = coalesce(str_c("Hi ", name, "!"), "Hi!")
  )

c(1, NA, NA, 2) %>% coalesce(3)

df |> mutate(greeting = str_glue("Hi {name}!"))
df |> mutate(greeting = str_glue("Hi {coalesce(name,'wow')}!"))
df |> mutate(greeting = str_glue("{{Hi {name}!}}"))
df |> mutate(greeting = str_glue("{{Hi {name}!}}"))

str_flatten(c("x", "y", "z"))
#> [1] "xyz"
str_flatten(c("x", "y", "z"), ", ")
#> [1] "x, y, z"
str_flatten(c("x", "y", "z"), ", ", last = ", and ")
#> [1] "x, y, and z"
paste(c("x", "y", "z", "a"), collapse = ", ")

df <- tribble(
  ~name, ~fruit,
  "Carmen", "banana",
  "Carmen", "apple",
  "Marvin", "nectarine",
  "Terence", "cantaloupe",
  "Terence", "papaya",
  "Terence", "mandarin"
)

df %>%
  group_by(name) %>%
  summarise(fruit = str_flatten(fruit, ", "))

## 练习
reprex::reprex({
  library(stringr)
  str_c("hi ", NA)
  str_c(letters[1:2], letters[1:3])
  paste0("hi ", NA)
  paste0(letters[1:2], letters[1:3])
})
paste0(letters[1:2], letters[1:3], recycle0 = FALSE)

paste("1", "2", "3")
paste0("1", "2", "3")
paste(c("1", "2", "3"), c("4", "5", "6"), sep = "")
paste0(c("1", "2", "3"), c("4", "5", "6"), collapse = ", ")
paste(c("1", "2", "3"), c("4", "5", "6"), sep = "", collapse = ", ")

str_c("1", "2", "3")
paste("1", "2", "3", sep = "")
str_c("Hello ", c("John", "Susan"))
paste("Hello ", c("John", "Susan"), sep = "")

str_glue("The price of {food} is {price}")
str_c("I'm ", age, " years old and live in ", country)
str_glue("\\\\section{{{title}}}")

# 字符串提取数据-----
df1 <- tibble(x = c("a,b,c", "d,e", "f"), y = 1:3)
df1 |>
  separate_longer_delim(x, delim = ",")
df2 <- tibble(x = c("1211", "131", "21"))
df2 |>
  separate_longer_position(x, width = 1)

df3 <- tibble(x = c("a10.1.2022", "b10.2.2011", "e15.1.2015"))
df3 %>%
  separate_wider_delim(
    x,
    delim = ".",
    names = c("code", "edition", "year")
  )
df3 %>%
  separate_wider_delim(
    x,
    delim = ".",
    names = c("code", NA, "year")
  )
df4 <- tibble(x = c("202215TX", "202122LA", "202325CA"))
df4 %>%
  separate_wider_position(
    x,
    widths = c(year = 4, age = 2, state = 2)
  )
df <- tibble(x = c("1-1-1", "1-1-2", "1-3", "1-3-2", "1"))
df %>%
  separate_wider_delim(
    x,
    delim = "-",
    names = c("x", "y", "z"),
    too_few = "debug"
  ) %>%
  filter(!x_ok)

df %>%
  separate_wider_delim(
    x,
    delim = "-",
    names = c("x", "y", "z"),
    too_few = "align_end"
  )

df <- tibble(x = c("1-1-1", "1-1-2", "1-3-5-6", "1-3-2", "1-3-5-7-9"))
df %>%
  separate_wider_delim(
    x,
    delim = "-",
    names = c("x", "y", "z"),
    too_many = "merge"
  )

str_split(df$x, "-")

str_length(c("a", "R for data science", NA))

babynames %>%
  count(length = str_length(name), wt = n)

x <- c("Apple", "Banana", "Pear")
str_sub(x, 1, 3)
str_sub(x, -3, -1)
str_sub("a", 1, 5)

babynames %>%
  mutate(
    first = str_sub(name, 1, 1),
    last = str_sub(name, -1, -1)
  )


babynames %>%
  mutate(
    length = str_length(name),
    mid = floor(length / 2),
    mid_letter = str_sub(name, length / 2, length / 2)
  )

babynames %>%
  group_by(year) %>%
  count(length = str_length(name), wt = n) %>%
  ggplot(aes(x = year, y = n, color = factor(length))) +
  geom_line() +
  labs(color = "Name length")
babynames %>%
  group_by(year) %>%
  count(first = str_sub(name, 1, 1), wt = n) %>%
  ggplot(aes(x = year, y = n, color = first)) +
  geom_line()
babynames %>%
  group_by(year) %>%
  count(last = str_sub(name, -1, -1), wt = n) %>%
  ggplot(aes(x = year, y = n, color = last)) +
  geom_line()

# 非英语文本-----
charToRaw("Hadley")
x1 <- "text\nEl Ni\xf1o was particularly bad this year"
read_csv(x1)$text
#> [1] "El Ni\xf1o was particularly bad this year"

x2 <- "text\n\x82\xb1\x82\xf1\x82\xc9\x82\xbf\x82\xcd"
read_csv(x2)$text
#> [1] "\x82\xb1\x82\xf1\x82ɂ\xbf\x82\xcd"

read_csv(x1, locale = locale(encoding = "Latin1"))$text
#> [1] "El Niño was particularly bad this year"

read_csv(x2, locale = locale(encoding = "Shift-JIS"))$text
#> [1] "こんにちは"
guess_encoding(x2)

u <- c("\u00fc", "u\u0308")
str_view(u)
str_length(u)
str_sub(u,1,1)
u[[1]]==u[[2]]
str_equal(u[[1]],u[[2]])

str_to_upper(c("i",'1'))
str_to_upper(c("i",'1'),locale = "tr")

str_sort(c("a", "c", "ch", "h", "z"))
#> [1] "a"  "c"  "ch" "h"  "z"
str_sort(c("a", "c", "ch", "h", "z"), locale = "cs")
#> [1] "a"  "c"  "h"  "ch" "z"