library(tidyverse)
library(nycflights13)
library(patchwork)
# 显性缺失值-------
treatment <- tribble(
  ~person, ~treatment, ~response,
  "Derrick Whitmore", 1, 7,
  NA, 2, 10,
  NA, 3, NA,
  "Katherine Burke", 1, 4
)
treatment %>%
  fill(everything())

x <- c(1, 4, 5, 7, -99)
x[x == -99] <- NA
x

x <- "
x
wow
NA
hey
99
"
x <- read_csv(x)
x

x <- c(1, 4, 5, 7, -99)
na_if(x, -99)

na_if(x, -99)

x <- c(NA, NaN)
x * 10
x == 1
is.na(x)
is.nan(x)

0 / 0
0 * Inf
Inf - Inf
sqrt(-1)

# 隐性缺失值---------
stocks <- tibble(
  year  = c(2020, 2020, 2020, 2020, 2021, 2021, 2021),
  qtr   = c(1, 2, 3, 4, 2, 3, 4),
  price = c(1.88, 0.59, 0.35, NA, 0.92, 0.17, 2.66)
)

stocks %>%
  pivot_wider(
    names_from = qtr,
    values_from = price
  ) %>%
  pivot_longer(
    cols = !year,
    names_to = "qtr",
    values_to = "price",
    values_drop_na = TRUE
  )

stocks %>%
  complete(year, qtr)

stocks %>%
  complete(year = 2019:2021, qtr)

flights %>%
  distinct(faa = dest) %>%
  anti_join(airports)
flights %>%
  distinct(tailnum) %>%
  anti_join(planes)

## 练习
flights %>%
  distinct(tailnum) %>%
  anti_join(planes) %>%
  left_join(flights, by = "tailnum") %>%
  distinct(tailnum, carrier)


# 因子与空组--------
health <- tibble(
  name   = c("Ikaia", "Oletta", "Leriah", "Dashay", "Tresaun"),
  smoker = factor(c("no", "no", "no", "no", "no"), levels = c("yes", "no")),
  age    = c(34, 88, 75, 47, 56),
)
health %>%
  count(smoker, .drop = FALSE)

p1 <- ggplot(health, aes(x = smoker)) +
  geom_bar()
p2 <- ggplot(health, aes(x = smoker)) +
  geom_bar() +
  scale_x_discrete(drop = FALSE)
p1 + p2

health %>%
  group_by(smoker, .drop = FALSE) %>%
  summarise(
    n = n(),
    mean_age = mean(age),
    min_age = min(age),
    max_age = max(age),
    sd_age = sd(age)
  )

x1 <- c(NA, NA)
length(x1)
x2 <- numeric()
length(x2)

health %>%
  group_by(smoker) %>%
  summarise(
    n = n(),
    mean_age = mean(age),
    min_age = min(age),
    max_age = max(age),
    sd_age = sd(age)
  ) %>%
  complete(smoker)
