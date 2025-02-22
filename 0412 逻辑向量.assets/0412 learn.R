library(tidyverse)
library(nycflights13)
library(dplyr)

# 比较----
x <- c(1 / 49 * 49, sqrt(2)^2)
x
#> [1] 1 2
x == c(1, 2)
#> [1] FALSE FALSE

class(x)
class(1:2)

print(x, digits = 16)
#> [1] 0.9999999999999999 2.0000000000000004

near(x, c(1, 2))

round(x) == 1:2

NA > 5
#> [1] NA
10 == NA
#> [1] NA
NA == NA
#> [1] NA

flights |>
  filter(dep_time == NA)

flights %>%
  filter(is.na(dep_time))

flights %>%
  filter(month == 1 & day == 1) %>%
  arrange(desc(is.na(dep_time)), dep_time)
## 练习
near(sqrt(2)^2, 2)

flights %>%
  mutate(res = 60 * (dep_time %/% 100 - sched_dep_time %/% 100) + dep_time %% 100 - sched_dep_time %% 100) %>%
  relocate(res, dep_delay)


flights %>%
  mutate(
    dep_time_na = is.na(dep_time),
    sched_dep_time_na = is.na(sched_dep_time),
    dep_delay_na = is.na(dep_delay),
  ) %>%
  count(dep_time_na, sched_dep_time_na, dep_delay_na)

# 布尔计算-----
df <- tibble(x = c(TRUE, FALSE, NA))

df |>
  mutate(
    and = x & NA,
    or = x | NA
  )
NA | TRUE
TRUE | NA
NA & TRUE
TRUE & NA

FALSE | NA
NA | FALSE
FALSE & NA
NA & FALSE

## 练习
flights %>%
  filter(is.na(arr_delay) & !is.na(dep_delay))
flights %>%
  filter(!is.na(arr_time) & !is.na(sched_arr_time) & is.na(arr_delay))

flights %>%
  filter(is.na(dep_time))



mydata <- flights %>%
  mutate(date = make_date(year, month, day)) %>%
  group_by(date) %>%
  summarise(
    mean_dep_delay = mean(dep_delay, na.rm = T),
    na_dep_delay = sum(is.na(dep_delay))
  )
mydata %>%
  ggplot(aes(x = date)) +
  geom_line(aes(y = na_dep_delay), color = "grey") +
  geom_line(aes(y = mean_dep_delay), color = "red") +
  scale_x_date(date_breaks = "1 month", date_labels = "%Y年%b") +
  labs(x = "日期", y = "平均延误时间(min)/取消数")
ggplot(mydata, aes(x = mean_dep_delay, y = na_dep_delay)) +
  geom_point()
lm(na_dep_delay ~ mean_dep_delay, data = mydata) %>% summary()

# 汇总-----
prod(c(TRUE, FALSE, TRUE))
all(c(TRUE, FALSE, TRUE))
min(c(TRUE, FALSE, TRUE)) %>% as.logical()

# 条件转换-----
x <- c(-3:3, NA)
if_else(x > 0, "positive", "negative")
if_else(x > 0, "positive", "negative", "missing")
if_else(x > 0, "positive", if_else(x < 0, "negative", "zero"), "missing")

x1 <- c(NA, 1, 2, NA)
y1 <- c(3, NA, 4, 6)
if_else(is.na(x1), y1, x1)

case_when(
  x > 0 ~ "positive",
  x < 0 ~ "negative",
  x == 0 ~ "zero",
  is.na(x) ~ "missing"
)
## 练习
ifelse(1:20 %% 2 == 0, "even", "odd")

x <- c("Monday", "Saturday", "Wednesday")
if_else(x == "Saturday" | x == "Sunday", "weekend", "weekday")
# 输出绝对值
reprex::reprex({
  library(dplyr)
  new_abs <- function(x) {
    if_else(x < 0, -x, x)
  }
  new_abs(-5)
  new_abs(-3:3)
})

library(dplyr)

flights %>%
  mutate(
    is_holiday = case_when(
      month == 1 & day == 1 ~ TRUE,
      month == 7 & day == 4 ~ TRUE,
      month == 11 & day >= 22 & day <= 28 ~ TRUE,
      month == 12 & day == 25 ~ TRUE,
      TRUE ~ FALSE
    ),
    holiday_name = case_when(
      is_holiday & month == 1 & day == 1 ~ "New Year's Day",
      is_holiday & month == 7 & day == 4 ~ "4th of July",
      is_holiday & month == 11 & day >= 22 & day <= 28 ~ "Thanksgiving",
      is_holiday & month == 12 & day == 25 ~ "Christmas",
      TRUE ~ NA_character_
    )
  ) %>%
  relocate(is_holiday, holiday_name)
