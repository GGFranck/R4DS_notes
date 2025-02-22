library(tidyverse)
library(nycflights13)
library(patchwork)
# 创建日期时间-----
today()
now()

csv <- "
  date,datetime
  2022-01-02,2022-01-02 05:12
"

csv <- "
date
01/02/15
"
read_csv(csv, col_types = cols(date = col_date("%m/%d/%y")))
read_csv(csv, col_types = cols(date = col_date("%d/%m/%y")))
read_csv(csv, col_types = cols(date = col_date("%y/%m/%d")))
csv <- "
date
01/Feb/15
"
read_csv(csv, col_types = cols(date = col_date("%y/%b/%d")))

ymd("2017-01-31")
ymd("2017/01/31")
mdy("January 31st, 2017")
dmy("31-Jan-2017")

ymd_hms("2017-01-31 20:11:59")
mdy_hm("01/31/2017 08:01")

ymd("2017-01-31", tz = "UTC")

flights %>%
  select(year, month, day, hour, minute) %>%
  mutate(
    departure1 = make_date(year, month, day),
    departure2 = make_datetime(year, month, day, hour, minute)
  )

make_datetime_100 <- function(year, month, day, time) {
  make_datetime(year, month, day, time %/% 100, time %% 100)
}
flights_dt <- flights %>%
  filter(!is.na(dep_time), !is.na(arr_time)) %>%
  mutate(
    dep_time = make_datetime_100(year, month, day, dep_time),
    arr_time = make_datetime_100(year, month, day, arr_time),
    sched_dep_time = make_datetime_100(year, month, day, sched_dep_time),
    sched_arr_time = make_datetime_100(year, month, day, sched_arr_time)
  ) %>%
  select(origin, dest, ends_with("delay"), ends_with("time"))
flights_dt %>%
  ggplot(aes(x = dep_time)) +
  geom_freqpoly(binwidth = 86400)

flights_dt %>%
  filter(dep_time < ymd(20130102)) %>%
  ggplot(aes(x = dep_time)) +
  geom_freqpoly(binwidth = 600)

# 改变日期展示形式,地区
reprex::reprex({
  library(lubridate)
  Sys.setlocale("LC_ALL", "en_US.UTF-8")
  format(ymd(20130209), "%Y/%B/%d")
  Sys.setlocale("LC_ALL", "zh_CN.UTF-8")
  format(ymd(20130209), "%Y/%B/%d")
})

reprex::reprex({
  library(lubridate)
  today()
  as_datetime(today())
  now()
  as_date(now())
})

as_datetime(60 * 60 * 10)
as_date(365 * 10 + 2)
## 练习
reprex::reprex({
  library(lubridate)
  ymd(c("2010-01-01", "2010-02-01"))
  ymd(c("2010-01-01", "bananas"))
})
ymd(c("2010-10-10", "bananas"))

today()
today("GMT+8")

d1 <- "January 1, 2010"
d2 <- "2015-Mar-07"
d3 <- "06-Jun-2017"
d4 <- c("August 19 (2015)", "July 1 (2015)")
d5 <- "12/30/14" # Dec 30, 2014
t1 <- "1705"
t2 <- "11:15:10.12 PM"

mdy(d1)
ymd(d2)
dmy(d3)
mdy(d4)
mdy(d5)
strptime(t1, "%H%M")
strptime(t2, "%I:%M:%OS %p")

parse_date_time(t1, orders = "HM")
parse_date_time(t2, orders = "HMS")

# 获取时间的组成------
datetime <- ymd_hms("2026-07-08 12:34:56")

year(datetime)
month(datetime)
day(datetime)
mday(datetime)
yday(datetime)
wday(datetime)
hour(datetime)
minute(datetime)
second(datetime)

month(datetime, label = TRUE)
wday(datetime, label = TRUE, abbr = FALSE)

flights_dt %>%
  mutate(wday = wday(dep_time, label = TRUE)) %>%
  ggplot(aes(x = wday)) +
  geom_bar()

flights_dt %>%
  mutate(minute = minute(dep_time)) %>%
  group_by(minute) %>%
  summarise(
    avg_delay = mean(dep_delay, na.rm = TRUE),
    n = n()
  ) %>%
  ggplot(aes(x = minute, y = avg_delay)) +
  geom_line()

flights_dt %>%
  mutate(minute = minute(sched_dep_time)) %>%
  group_by(minute) %>%
  summarise(
    avg_delay = mean(arr_delay, na.rm = TRUE),
    n = n()
  ) %>%
  ggplot(aes(x = minute, y = avg_delay)) +
  geom_line()

flights_dt %>%
  mutate(minute = minute(sched_dep_time)) %>%
  ggplot(aes(x = minute)) +
  geom_freqpoly(binwidth = 1) +
  xlim(0, 60)


# 随机生成一些时间
set.seed(1234)
a <- round(runif(20, min = 0, max = 365)) + ymd("20240101")
a <- sort(a)
a <- tibble(
  origin = a,
  floor = floor_date(a, "week"),
  round = round_date(a, "week"),
  ceiling = ceiling_date(a, "week")
)
wday(a$origin, label = TRUE)
wday(a$floor, label = TRUE)

flights_dt %>%
  count(week = floor_date(dep_time, "week")) %>%
  ggplot(aes(x = week, y = n)) +
  geom_line() +
  geom_point()


a <- round(runif(10, min = 0, max = 60 * 60 * 24)) + ymd_hms("20240101 00:00:00")
a <- sort(a)
a
floor_date(a, "day")
diff_a <- a - floor_date(a, "day")
hms::as_hms(diff_a)

flights_dt %>%
  mutate(dep_hour = dep_time - floor_date(dep_time, "day")) %>%
  ggplot(aes(x = dep_hour)) +
  geom_freqpoly(binwidth = 60 * 30)


flights_dt %>%
  mutate(dep_hour = hms::as_hms(dep_time - floor_date(dep_time, "day"))) %>%
  ggplot(aes(x = dep_hour)) +
  geom_freqpoly(binwidth = 60 * 30)

datetime <- ymd_hms("2026-07-08 12:34:56")
year(datetime) <- 2030
month(datetime) <- 01
hour(datetime) <- hour(datetime) + 1
datetime
update(datetime, year = 2030, month = 2, mday = 2, hour = 2)
update(ymd(20230201), mday = 30)
update(ymd(20230201), hour = 400)
## 练习
flights %>%
  count(year, month, day) %>%
  mutate(date = make_date(year, month, day)) %>%
  ggplot(aes(x = date, y = n)) +
  geom_line()

flights %>%
  mutate(
    dep_delay2 = parse_date_time(dep_time, orders = "HM") - parse_date_time(sched_dep_time, orders = "HM"),
    dep_delay2 = as.numeric(dep_delay2, units = "mins"),
    dep_delay = dep_delay,
    .keep = "used"
  )

flights %>%
  mutate(
    dep_time = make_datetime(year, month, day, dep_time %/% 100, dep_time %% 100),
    arr_time = make_datetime(year, month, day, arr_time %/% 100, arr_time %% 100),
    air_time2 = as.numeric(arr_time - dep_time),
    air_time2 = ifelse(air_time2 < 0, air_time2 + 60 * 24, air_time2),
    air_time = air_time,
    .keep = "used"
  ) %>%
  head(n = 1000) %>%
  ggplot(aes(x = air_time, y = air_time2)) +
  geom_point() +
  ylab("arr-dep")


flights %>%
  mutate(
    hour2 = parse_date_time(dep_time, "HM"),
    hour2 = hms::as_hms(hour2),
  ) %>%
  group_by(hour2) %>%
  summarise(mean_dep_delay = mean(dep_delay)) %>%
  ggplot(aes(x = hour2, y = mean_dep_delay)) +
  geom_line()

Sys.setlocale("LC_ALL", "en_US.UTF-8")
flights %>%
  mutate(
    week_day = wday(time_hour, label = TRUE, abbr = FALSE),
  ) %>%
  group_by(week_day) %>%
  summarise(
    avg_delay = mean(dep_delay, na.rm = TRUE),
    n = n()
  ) %>%
  ggplot(aes(x = week_day, y = avg_delay)) +
  geom_bar(stat = "identity") +
  geom_line()

Sys.setlocale("LC_ALL", "en_US.UTF-8")
flights %>%
  mutate(
    week_day = wday(time_hour, label = TRUE, abbr = FALSE),
  ) %>%
  group_by(week_day) %>%
  summarise(
    prop_delay = mean(dep_delay <= 0, na.rm = TRUE),
    n = n()
  ) %>%
  ggplot(aes(x = week_day, y = prop_delay)) +
  geom_bar(stat = "identity")

p1 <- flights_dt %>%
  mutate(minute = minute(dep_time)) %>%
  group_by(minute) %>%
  summarise(
    avg_delay = mean(dep_delay, na.rm = TRUE),
    n = n()
  ) %>%
  ggplot(aes(x = minute, y = avg_delay)) +
  geom_line()

p2 <- flights_dt %>%
  mutate(minute = minute(dep_time)) %>%
  group_by(minute) %>%
  summarise(
    prop_delay = mean(dep_delay > 0, na.rm = TRUE),
    n = n()
  ) %>%
  ggplot(aes(x = minute, y = prop_delay)) +
  geom_line()

p1 / p2

# 时间跨度---------
h_age <- today() - ymd(19791014)
h_age
as.duration(h_age)
dseconds(15)
dminutes(10)
dhours(c(12, 24))
ddays(0:5)
dweeks(3)
dyears(1)

2 * dyears(1)
dyears(1) + dweeks(12) + dhours(15)
tomorrow <- today() + ddays(1)
last_year <- today() - dyears(1)
tomorrow
last_year

one_am <- ymd_hms("2026-03-08 01:00:00", tz = "America/New_York")
one_am
one_am + ddays(1)

one_am
one_am + days(1)
as.period(2)
seconds(2)
hours(c(12, 24))
days(7)
months(1:6)

10 * (months(6) + days(1))
days(50) + hours(25) + minutes(2)

ymd("2024-01-01") + dyears(1)
ymd("2024-01-01") + years(1)

one_am + ddays(1)
one_am + days(1)

flights_dt %>%
  filter(arr_time < dep_time)
flights_dt <- flights_dt %>%
  mutate(
    overnight = arr_time < dep_time,
    arr_time = arr_time + days(overnight),
    sched_arr_time = sched_arr_time + days(overnight),
  )

dyears(1) / ddays(1)
years(1) / days(1)

y2023 <- ymd("2023-01-01") %--% ymd("2024-01-01")
y2024 <- ymd("2024-01-01") %--% ymd("2025-01-01")
y2023
y2024

y2023 / days(1)
y2024 / days(1)

y2023 / ddays(1)
y2024 / ddays(1)

dyears(1) / days(1)
## 练习
ymd(20150101) + months(0:11)
floor_date(today(), "year") + months(0:11)

how_old <- function(birthday) {
  age <- ymd(birthday) %--% today()
  age <- as.period(age)
  return(age)
}
how_old(20010722)

(today() %--% (today() + years(1))) / months(1)

# 时区-------
Sys.timezone()
length(OlsonNames())
head(OlsonNames())

x1 <- ymd_hms("2024-06-01 12:00:00", tz = "America/New_York")
x1
x2 <- ymd_hms("2024-06-01 18:00:00", tz = "Europe/Copenhagen")
x2
x3 <- ymd_hms("2024-06-02 04:00:00", tz = "Pacific/Auckland")
x3
x1 - x2
x1 - x3
ymd_hms("2024-06-01 12:00:00", tz = "Asia/Shanghai")

x4 <- c(x1, x2, x3)
x4
x4
with_tz(x4, tzone = "Australia/Lord_Howe")
force_tz(x4, tzone = "Australia/Lord_Howe")
