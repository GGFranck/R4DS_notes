library(tidyverse)
library(dplyr)
library(lubridate)
library(stringr)
library(nycflights13)
library(epiDisplay)
# install.packages("e1071")
library(e1071)
library(ggplot2)
# 向量函数-----
df <- tibble(
  a = rnorm(5),
  b = rnorm(5),
  c = rnorm(5),
  d = rnorm(5),
)

df |> mutate(
  a = (a - min(a, na.rm = TRUE)) /
    (max(a, na.rm = TRUE) - min(a, na.rm = TRUE)),
  b = (b - min(a, na.rm = TRUE)) /
    (max(b, na.rm = TRUE) - min(b, na.rm = TRUE)),
  c = (c - min(c, na.rm = TRUE)) /
    (max(c, na.rm = TRUE) - min(c, na.rm = TRUE)),
  d = (d - min(d, na.rm = TRUE)) /
    (max(d, na.rm = TRUE) - min(d, na.rm = TRUE)),
)

rescale01 <- function(x) {
  (x - min(x, na.rm = TRUE)) /
    (max(x, na.rm = TRUE) - min(x, na.rm = TRUE))
}
rescale01(c(-10, 0, 10))
rescale01(c(1, 2, 3, NA, 5))

df %>% mutate(
  a = rescale01(a),
  b = rescale01(b),
  c = rescale01(c),
  d = rescale01(d)
)
df %>%
  mutate(across(a:d, rescale01))

rescale01 <- function(x) {
  rng <- range(x, na.rm = TRUE)
  (x - rng[1]) / (rng[2] - rng[1])
}
x <- c(1:10, Inf)
rescale01(x)

rescale01 <- function(x) {
  rng <- range(x, na.rm = TRUE, finite = TRUE)
  (x - rng[1]) / (rng[2] - rng[1])
}
rescale01(x)

z_score <- function(x) {
  (x - mean(x, na.rm = TRUE)) / sd(x, na.rm = TRUE)
}

clamp <- function(x, min, max) {
  case_when(
    x < min ~ min,
    x > max ~ max,
    .default = x
  )
}
clamp(1:10, min = 3, max = 7)

first_upper <- function(x) {
  substr(x, 1, 1) <- str_to_upper(substr(x, 1, 1))
  x
}
first_upper(c("hello", "world"))

clean_number <- function(x) {
  is.pct <- str_detect(x, "%")
  num <- x %>%
    str_remove_all("%") %>%
    str_remove_all(",") %>%
    str_remove_all(fixed("$")) %>%
    as.numeric()
  ifelse(is.pct, num / 100, num)
}
clean_number("10%")
clean_number("$10,000")

fix_na <- function(x) {
  if_else(x %in% c(997, 998, 999), NA, x)
}

commas <- function(x) {
  str_flatten(x, collapse = ", ", last = " and ")
}
commas(c("cat", "dog", "pigeon"))

cv <- function(x, na.rm = FALSE) {
  sd(x, na.rm = na.rm) / mean(x, na.rm = na.rm)
}
cv(runif(100, min = 0, max = 50))
cv(runif(100, min = 0, max = 500))

n_missing <- function(x) {
  sum(is.na(x))
}
n_missing(sample(c(NA, 1, 2), 100, replace = TRUE))

mape <- function(actual, predicted) {
  sum(abs((actual - predicted) / actual)) / length(actual)
}
## 练习
percent_na <- function(x) {
  mean(is.na(x))
}
prop <- function(x) {
  x / sum(x, na.rm = TRUE)
}
percent(1:10) <- function(x) {
  round(x / sum(x, na.rm = TRUE) * 100, 1)
}

rescale01 <- function(x) {
  rng <- range(x, na.rm = TRUE, finite = TRUE)
  case_when(
    x == -Inf ~ 0,
    x == Inf ~ 1,
    .default = (x - rng[1]) / (rng[2] - rng[1])
  )
}
x <- c(-Inf, 1:10, Inf)
rescale01(x)

set.seed(1234)
birthdays <- runif(20, as.Date("2001-01-01"), as.Date("2017-12-31")) %>%
  as_date()
age <- function(x) {
  (today() - x) %>%
    as.period() %>%
    as.numeric(units = "year")
}
age(birthdays)

(today() - ymd("2001-01-01")) %>%
  as.period() %>%
  as.numeric(units = "years") %>%
  round(1)

variance <- function(x) {
  sum((x - mean(x, na.rm = TRUE))^2) / (length(x) - 1)
}
skew <- function(x) {
  mean(((x - mean(x, na.rm = TRUE)) / sd(x, na.rm = TRUE))^3)
}

variance(1:10)
var(1:10)
skew(c(1, 1:6))
skewness(c(1, 1:6))

both_na <- function(x, y) {
  if (length(x) != length(y)) {
    stop("x and y must be the same length", call. = FALSE)
  } else {
    c(1:length(x))[is.na(x) & is.na(y)]
  }
}
x <- c(1, NA, 3, NA)
y <- c(2, NA, 6)
y <- c(2, NA, 6, NA)
both_na(x, y)

is_directory <- function(x) {
  file.info(x)$isdir
}
is_readable <- function(x) {
  file.access(x, 4) == 0
}

setwd("D:/Data/知识库/R语言基础/R4DS学习笔记/0625 函数.assets")
is_directory("./test")
is_directory("./test/test.txt")
file.info("./test/test.txt")
file.access("./test/test.txt")

# 数据框函数--------
grouped_mean <- function(df, group_var, mean_var) {
  df %>%
    group_by(group_var) %>%
    summarise(mean(mean_var))
}
diamonds %>% grouped_mean(cut, carat)

df <- tibble(
  mean_var = 1,
  group_var = "g",
  group = 1,
  x = 10,
  y = 100
)
df %>% grouped_mean(group, x)
df %>% grouped_mean(group, y)

df <- tibble(
  x = 1:3,
  y = 1:3 * (-1)
)
y <- 1
df %>%
  mutate(x = y)
df %>%
  mutate(x = {{ y }})

grouped_mean <- function(df, group_var, mean_var) {
  df %>%
    group_by({{ group_var }}) %>%
    summarise(mean({{ mean_var }}))
}
df %>% grouped_mean(group, y)

summary6 <- function(data, var) {
  data %>% summarise(
    min = min({{ var }}, na.rm = TRUE),
    mean = mean({{ var }}, na.rm = TRUE),
    median = median({{ var }}, na.rm = TRUE),
    max = max({{ var }}, na.rm = TRUE),
    n = n(),
    n_missing = sum(is.na({{ var }})),
    .groups = "drop"
  )
}
diamonds %>% summary6(carat)
library(epiDisplay)
epiDisplay::summ(diamonds$carat)

diamonds %>%
  group_by(cut) %>%
  summary6(carat)

diamonds %>%
  group_by(cut) %>%
  summary6()

count_prop <- function(df, var, sort = FALSE) {
  df %>%
    count({{ var }}, sort = sort) %>%
    mutate(prop = n / sum(n))
}
diamonds %>% count_prop(clarity)

unique_where <- function(df, condition, var) {
  df %>%
    filter({{ condition }}) %>%
    distinct({{ var }}) %>%
    arrange({{ var }})
}
flights %>% unique_where(month == 12, dest)

subset_flights <- function(rows, cols) {
  flights %>%
    filter({{ rows }}) %>%
    dplyr::select(time_hour, carrier, flight, {{ cols }})
}
subset_flights(month == 12, dep_delay)

count_missing <- function(df, group_vars, x_var) {
  df %>%
    group_by({{ group_vars }}) %>%
    summarise(
      n_missing = sum(is.na({{ x_var }})),
      .groups = "drop"
    )
}
flights %>% count_missing(c(year, month, day), dep_time)

count_missing <- function(df, group_vars, x_var) {
  df |>
    group_by(pick({{ group_vars }})) |>
    summarize(
      n_miss = sum(is.na({{ x_var }})),
      .groups = "drop"
    )
}

flights |>
  count_missing(c(year, month, day), dep_time)

count_wide <- function(data, rows, cols) {
  data %>%
    count(pick(c({{ rows }}, {{ cols }}))) %>%
    pivot_wider(
      names_from = {{ cols }},
      values_from = n,
      names_sort = TRUE,
      values_fill = 0
    )
}
diamonds %>% count_wide(c(clarity, color), cut)

## 练习
filter_severe <- function(df) {
  df %>%
    filter(is.na(arr_time) | dep_delay > 60)
}
flights |> filter_severe()
summarize_severe <- function(df) {
  df %>%
    summarise(
      severe = sum(is.na(arr_time) | dep_delay > 60)
    )
}
flights |>
  group_by(dest) |>
  summarize_severe()

filter_severe <- function(df, hours) {
  df %>%
    filter(is.na(arr_time) | dep_delay > hours * 60)
}
flights |> filter_severe(hours = 2)

summarize_weather <- function(df, var) {
  df %>%
    summarise(
      min = min({{ var }}, na.rm = TRUE),
      mean = mean({{ var }}, na.rm = TRUE),
      max = max({{ var }}, na.rm = TRUE),
    )
}
weather |> summarize_weather(temp)

standardize_time <- function(df, var) {
  df %>%
    mutate({{ var }} := {{ var }} %% 100 / 60 + {{ var }} %/% 100)
}
flights |> standardize_time(sched_dep_time)

count_prop <- function(df, var, sort = FALSE) {
  df |>
    count(pick({{ var }}), sort = sort) |>
    mutate(prop = n / sum(n))
}
flights %>% count_prop(c(carrier, origin))
flights %>%
  count(c(carrier, origin))

# 绘图函数------
diamonds %>%
  ggplot(aes(x = carat)) +
  geom_histogram(binwidth = 0.1)
diamonds %>%
  ggplot(aes(x = carat)) +
  geom_histogram(binwidth = 0.05)

histgram <- function(df, var, binwidth = NULL) {
  df %>%
    ggplot(aes(x = {{ var }})) +
    geom_histogram(binwidth = binwidth)
}
diamonds %>%
  histgram(carat) +
  labs(x = "Size (in carats)", y = "Number of diamonds")

linear_check <- function(df, x, y) {
  df %>%
    ggplot(aes(x = {{ x }}, y = {{ y }})) +
    geom_point() +
    geom_smooth(method = "loess", formula = y ~ x, color = "red", se = FALSE) +
    geom_smooth(method = "lm", formula = y ~ x, color = "blue", se = FALSE)
}
starwars %>%
  filter(mass < 1000) %>%
  linear_check(mass, height)

?stat_summary_hex
hex_plot <- function(df, x, y, z, bins = 20, fun = "mean") {
  df %>%
    ggplot(aes(x = {{ x }}, y = {{ y }}, z = {{ z }})) +
    stat_summary_hex(
      aes(color = after_scale(fill)), # 让fill和scale一样的颜色
      bins = bins,
      fun = fun
    )
}
diamonds %>% hex_plot(carat, price, depth)

sorted_bars <- function(df, var) {
  df %>%
    mutate({{ var }} := fct_rev(fct_infreq({{ var }}))) %>%
    ggplot(aes(y = {{ var }})) +
    geom_bar()
}
diamonds %>% sorted_bars(clarity)

conditional_bars <- function(df, condition, var) {
  df %>%
    filter({{ condition }}) %>%
    ggplot(aes(x = {{ var }})) +
    geom_bar()
}
diamonds %>% conditional_bars(cut == "Good", clarity)

a <- "wow"
str_glue("hello {{a}}")

histogram <- function(df, var, binwidth) {
  label <- rlang::englue("A histogram of {{var}} with binwidth {{binwidth}}")

  df %>%
    ggplot(aes(x = {{ var }})) +
    geom_histogram(binwidth = binwidth) +
    labs(title = label)
}
diamonds %>% histogram(carat, 0.1)

diamonds
xy_scatter <- function(df, x, y) {
  label <- rlang::englue("A scatter plot of {{x}} vs. {{y}}")
  df %>%
    ggplot(aes(x = {{ x }}, y = {{ y }})) +
    geom_point() +
    geom_smooth(se = FALSE)
}
diamonds %>% xy_scatter(carat, price)

# 风格-----
?coef()
x <- 1:5
coef(lm(c(1:3, 7, 6) ~ x))

## 练习
f1 <- function(string, prefix) {
  str_sub(string, 1, str_length(prefix)) == prefix
}
f3 <- function(x, y) {
  rep(y, length.out = length(x))
}

