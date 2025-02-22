library(tidyverse)
library(dplyr)
library(nycflights13)
# 得到数字-----
x <- c("1.2", "5.6", "1e3")
parse_double(x)
x <- c("$1,234", "USD 3,513", "59%")
parse_number(x)

flights %>%
  count(dest, sort = T)

flights %>%
  group_by(dest) %>%
  summarise(
    n = n(),
    delay = mean(arr_delay, na.rm = T)
  )

flights %>%
  group_by(dest) %>%
  summarise(carriers = n_distinct(carrier)) %>%
  arrange(desc(carriers))

flights %>%
  group_by(dest) %>%
  distinct(carrier) %>%
  count() %>%
  arrange(desc(n))

flights |> count(tailnum, wt = distance)

flights |>
  group_by(tailnum) |>
  summarize(miles = sum(distance))

flights %>%
  group_by(dest) %>%
  summarise(n_cancelled = sum(is.na(dep_time)))

table(flights$dest, is.na(flights$dep_time))

## 练习
flights %>%
  group_by(is.na(dep_time)) %>%
  count()


flights |> count(dest, sort = TRUE)
flights |> count(tailnum, wt = distance)

flights %>%
  group_by(dest) %>%
  summarise(n = n()) %>%
  arrange(desc(n))

flights %>%
  group_by(tailnum) %>%
  summarise(miles = sum(distance))


aggregate(flights$dep_delay^0, by = list(dest = flights$dest), sum)
aggregate(flights$distance, by = list(tailnum = flights$tailnum), sum)

# 数值转换----
df <- tribble(
  ~x, ~y,
  1, 3,
  5, 2,
  7, NA,
)

df |>
  mutate(
    min = pmin(x, y, na.rm = TRUE),
    max = pmax(x, y, na.rm = TRUE)
  )
df |>
  mutate(
    min = min(x, y, na.rm = TRUE),
    max = max(x, y, na.rm = TRUE)
  )
apply(df, 1, min, na.rm = T)
apply(df, 1, max, na.rm = T)

1:10 %/% 3
1:10 %% 3

flights %>%
  group_by(hour = sched_dep_time %/% 100) %>%
  summarise(prop_cancelled = mean(is.na(dep_time)), n = n()) %>%
  filter(hour > 1) %>%
  ggplot(aes(x = hour, y = prop_cancelled)) +
  geom_line(color = "grey50") +
  geom_point(aes(size = n))


round(123.456, 1.5)
round(c(1.5, 2.5))

x <- c(1, 2, 5, 10, 15, 20)
cut(x, breaks = c(0, 5, 10, 15, 20), right = TRUE, include.lowest = T)

reprex::reprex({
  cumsum(1:10)
  cumprod(1:10)
  cummax(1:10)
  cummin(1:10)
})
## 练习
sin(1 / 6 * pi)
sinpi(1 / 6)

flights |>
  filter(month == 1, day == 1) |>
  mutate(
    hour = sched_dep_time %/% 100,
    minute = sched_dep_time %% 100,
    time = make_datetime(year, month, day, hour, minute)
  ) %>%
  ggplot(aes(x = time, y = dep_delay)) +
  geom_point() +
  scale_x_datetime(date_breaks = "2 hour", date_labels = "%H")
# Round `dep_time` and `arr_time` to the nearest five minutes.

round(flights$dep_time / 5) * 5

round(flights$arr_time / 5) * 5

# 通用转换-----
x <- c(1, 2, 2, 3, 4, NA)
min_rank(x)
library(dplyr)
df <- tibble(x = x)
df |>
  mutate(
    row_number = row_number(x),
    dense_rank = dense_rank(x),
    percent_rank = percent_rank(x),
    cume_dist = cume_dist(x)
  )
rank(x)
rank(x, ties.method = "min", na.last = "keep")

events <- tibble(
  time = c(0, 1, 2, 3, 5, 10, 12, 15, 17, 19, 20, 27, 28, 30)
)
attach(events)
lag(time, default = first(time))

df <- tibble(
  x = c("a", "a", "a", "b", "c", "c", "d", "e", "a", "a", "b", "b"),
  y = c(1, 2, 3, 2, 4, 1, 3, 9, 4, 8, 10, 199)
)
df |>
  group_by(id = consecutive_id(x)) |>
  slice_head(n = 1)
consecutive_id(c(1, 1, 1, 2, 1, 1, 2, 2))
## 练习
flights %>%
  mutate(rank = min_rank(-dep_delay)) %>%
  relocate(rank, dep_delay) %>%
  arrange(rank) %>%
  head(20)
flights %>%
  arrange(-dep_delay) %>%
  relocate(tailnum, dep_delay)
flights %>%
  group_by(hour) %>%
  summarise(prob_dep_delay = mean(is.na(dep_delay))) %>%
  filter(hour > 1) %>%
  arrange(prob_dep_delay) %>%
  mutate(rank = min_rank(prob_dep_delay))

flights |>
  group_by(dest) |>
  filter(row_number() < 4)

flights %>%
  group_by(dest) %>%
  slice_head(n = 3)

flights |>
  group_by(dest) |>
  filter(row_number(dep_delay) < 4)

flights %>%
  group_by(dest) %>%
  mutate(total_delay = sum(dep_delay, na.rm = T)) %>%
  select(total_delay)

flights %>%
  group_by(hour) %>%
  summarise(mean_dep_delay = mean(dep_delay, na.rm = T)) %>%
  mutate(mean_dep_delay_lag = lag(mean_dep_delay)) %>%
  filter(hour > 5) %>%
  ggplot(aes(x = mean_dep_delay, y = mean_dep_delay_lag)) +
  geom_point() +
  geom_smooth()

flights %>%
  mutate(v = distance / air_time) %>%
  arrange(v) %>%
  relocate(v)

flights %>%
  group_by(dest) %>%
  slice_min(air_time, n = 1) %>%
  relocate(dest, air_time)

flights %>%
  group_by(tailnum) %>%
  slice_max(arr_delay) %>%
  relocate(tailnum, arr_delay)

flights |>
  mutate(hour = dep_time %/% 100) |>
  group_by(year, month, day, hour) |>
  summarize(
    dep_delay = mean(dep_delay, na.rm = TRUE),
    n = n(),
    .groups = "drop"
  ) |>
  filter(n > 5)

flights %>%
  group_by(dest, carrier) %>%
  summarise(
    mean_dep_delay = mean(dep_delay, na.rm = TRUE), cancel = sum(is.na(dep_delay))
  ) %>%
  mutate(rank = min_rank(mean_dep_delay)) %>%
  arrange(dest, desc(rank)) %>%
  filter(rank > 1)

# 数值汇总----
reprex::reprex({
  quantile(1:20)
  quantile(1:20, 0.5)
  median(1:20)
})

IQR(1:20) == quantile(1:20, 0.75) - quantile(1:20, 0.25)

flights |>
  filter(dep_delay < 120) |>
  ggplot(aes(x = dep_delay, group = interaction(day, month))) +
  geom_freqpoly(binwidth = 5, alpha = 1 / 5)
reprex::reprex({
  library(dplyr)
  first(1:20)
  last(1:20)
  nth(1:20, 3)
})


set.seed(1234)
a <- runif(10)
first(a)
first(a,order_by = -a)

## 练习
flights %>%
  group_by(dest) %>%
  summarise(sd = sd(distance / air_time, na.rm = T)) %>%
  relocate(dest, sd) %>% 
  arrange(desc(sd))

flights %>%
  filter(dest == "EGE") %>%
  group_by(origin, year, month, day) %>%
  summarise(
    mean_dist = mean(distance, na.rm = T),
    date = make_date(year, month, day)
  ) %>%
  ggplot(aes(x = date, y = mean_dist)) +
  geom_point(aes(color = origin)) +
  scale_x_date(date_breaks = "1 month", date_labels = "%Y年%b")

flights %>%
  filter(dest == "EGE") %>%
  group_by(origin, year, month, day) %>%
  summarise(
    mean_dist = mean(air_time, na.rm = T),
    date = make_date(year, month, day)
  ) %>%
  ggplot(aes(x = date, y = mean_dist)) +
  geom_point(aes(color = origin)) +
  scale_x_date(date_breaks = "1 month", date_labels = "%Y年%b")
