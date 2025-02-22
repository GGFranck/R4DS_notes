library(tidyverse)
library(nycflights13)

# 键------------
airlines
airports
planes
weather

planes %>%
  count(tailnum) %>%
  filter(n > 1)
weather %>%
  count(time_hour, origin) %>%
  filter(n > 1)

planes %>%
  filter(is.na(tailnum))
weather %>%
  filter(is.na(time_hour) | is.na(origin))

flights %>%
  count(time_hour, carrier, flight) %>%
  filter(n > 1)

flights2 <- flights %>%
  mutate(id = row_number(), .before = 1)
flights2

view(airports)
view(weather)
## 练习
intersect(airports$faa, weather$origin)
flights$origin %>% unique()
flights$dest %>% unique()
intersect(airports$faa, flights$dest)

weather %>%
  count(year, month, day, hour, origin) %>%
  filter(n > 1)

weather %>%
  complete(day, hour) %>%
  filter(year == 2013, month == 11, day %in% 2:3) %>%
  view()

library(Lahman)
a <- colnames(Batting)
b <- colnames(People)
c <- colnames(Salaries)
intersect(a, b)
intersect(a, c)
intersect(b, c)
head(Batting)
head(People)
head(Salaries)

a <- colnames(People)
b <- colnames(Managers)
c <- colnames(AwardsManagers)
intersect(a, b)
intersect(a, c)
intersect(b, c)
head(People)
head(Managers)
head(AwardsManagers)

a <- colnames(Batting)
b <- colnames(Pitching)
c <- colnames(Fielding)
intersect(a, b)
intersect(a, c)
intersect(b, c)
head(Batting)
head(Pitching)
head(Fielding)

# 基本连接方式------
flights2 <- flights %>%
  select(year, time_hour, origin, dest, tailnum, carrier)
flights2
flights2 %>%
  left_join(airlines)

flights2 %>%
  left_join(weather %>% select(origin, time_hour, temp, wind_speed))

flights2 %>%
  left_join(planes %>% select(tailnum, type, engines, seats))

flights2 %>%
  filter(tailnum == "N3ALAA") %>%
  left_join(planes %>% select(tailnum, type, engines, seats))
any(flights2$tailnum == "N3ALAA")
any(planes$tailnum == "N3ALAA")
flights2 %>%
  left_join(planes, join_by(tailnum), suffix = c("", "_plane"))

flights2 %>%
  left_join(airports, join_by(dest == faa))

airports %>%
  semi_join(flights2, join_by(faa == origin))
flights2 %>%
  anti_join(airports, join_by(dest == faa)) %>%
  distinct(dest)

## 练习-------
my_flights <- flights %>%
  mutate(dep_time2 = make_datetime(year, month, day, dep_time %/% 100, dep_time %% 100))
my_flights
min(my_flights$dep_time2, na.rm = TRUE)
max(my_flights$dep_time2, na.rm = TRUE)
dep_delay_48h <- tibble(
  begin = seq(from = ymd_hms("2013-01-01 00:00:00"), to = ymd_hms("2014-01-01 00:00:00"), by = "1 hour"),
  end = begin + dhours(48),
  dep_delay = NA
)
for (i in 1:nrow(dep_delay_48h)) {
  dep_delay_48h$dep_delay[i] <- mean(my_flights$dep_delay[my_flights$dep_time2 >= dep_delay_48h$begin[i] & my_flights$dep_time2 < dep_delay_48h$end[i]], na.rm = TRUE)
}
dep_delay_48h %>%
  arrange(desc(dep_delay))
weather %>%
  filter(time_hour >= ymd_hms("2013-03-07 12:00:00") & time_hour <= ymd_hms("2013-03-09 12:00:00")) %>%
  view()

top_dest <- flights2 |>
  count(dest, sort = TRUE) |>
  head(10)
flights %>%
  left_join(top_dest)

flights %>%
  left_join(weather, join_by(year, month, day, hour, origin)) %>%
  filter(is.na(temp))

flights %>%
  anti_join(planes, join_by(tailnum)) %>%
  distinct(tailnum, carrier) %>%
  count(carrier)

tc <- flights %>%
  distinct(tailnum, carrier) %>%
  arrange(tailnum) %>%
  group_by(tailnum) %>%
  mutate(carrier_all = paste(carrier, collapse = ","))

planes %>%
  left_join(tc, join_by(tailnum)) %>%
  filter(str_detect(carrier_all, ","))

flights %>%
  left_join(airports %>% select(faa, origin_lat = lat, origin_lon = lon), join_by(origin == faa)) %>%
  left_join(airports %>% select(faa, dest_lat = lat, dest_lon = lon), join_by(dest == faa))


avg_delay_dest <- flights %>%
  group_by(dest) %>%
  summarise(avg_arr_delay = mean(arr_delay, na.rm = TRUE))

airports |>
  semi_join(flights, join_by(faa == dest)) |>
  left_join(avg_delay_dest, join_by(faa == dest)) %>%
  ggplot(aes(x = lon, y = lat)) +
  borders("state") +
  geom_point(aes(size = avg_arr_delay, color = avg_arr_delay)) +
  coord_quickmap() +
  scale_color_gradient(low = "white", high = "red")

avg_delay_dest_20230613 <- flights %>%
  filter(year == 2013, month == 6, day == 13) %>%
  group_by(dest) %>%
  summarise(avg_arr_delay = mean(arr_delay, na.rm = TRUE))

airports |>
  semi_join(flights, join_by(faa == dest)) |>
  left_join(avg_delay_dest_20230613, join_by(faa == dest)) %>%
  ggplot(aes(x = lon, y = lat)) +
  borders("state") +
  geom_point(aes(size = avg_arr_delay, color = avg_arr_delay)) +
  coord_quickmap() +
  scale_color_gradient(low = "white", high = "red")

# 连接的原理-------
x <- tribble(
  ~key, ~val_x,
  1, "x1",
  2, "x2",
  3, "x3"
)
y <- tribble(
  ~key, ~val_y,
  1, "y1",
  2, "y2",
  3, "y3"
)
left_join(x, y, by = "key")

df1 <- tibble(key = c(1, 2, 2), val_x = c("x1", "x2", "x3"))
df2 <- tibble(key = c(1, 2, 2), val_y = c("y1", "y2", "y3"))
inner_join(df1, df2, by = "key")
left_join(df1, df2, by = "key", relationship = "many-to-many")


x |> inner_join(y, join_by(key == key), keep = TRUE)
x %>% inner_join(y, join_by(key >= key), keep = TRUE)

# 非等值连接------
df <- tibble(name = c("John", "Simon", "Tracy", "Max"))
df %>% cross_join(df)

df <- tibble(id = 1:4, name = c("John", "Simon", "Tracy", "Max"))
df |> inner_join(df, join_by(id < id))
df

df1 <- tibble(key = c(1, 2, 3), val_x = c("x1", "x2", "x3"))
df2 <- tibble(key = c(1, 2, 4), val_y = c("y1", "y2", "y3"))
inner_join(df1, df2, join_by(closest(key <= key)))

parties <- tibble(
  q = 1:4,
  party = ymd(c("2022-01-10", "2022-04-04", "2022-07-11", "2022-10-03"))
)

set.seed(123)
employees <- tibble(
  name = sample(babynames::babynames$name, 100),
  birthday = ymd("2022-01-01") + (sample(365, 100, replace = TRUE) - 1)
)
employees
employees %>%
  left_join(parties, join_by(closest(birthday >= party))) %>%
  arrange(birthday)
employees |>
  anti_join(parties, join_by(closest(birthday >= party)))

parties <- tibble(
  q = 1:4,
  party = ymd(c("2022-01-10", "2022-04-04", "2022-07-11", "2022-10-03")),
  start = ymd(c("2022-01-01", "2022-04-04", "2022-07-11", "2022-10-03")),
  end = ymd(c("2022-04-03", "2022-07-11", "2022-10-02", "2022-12-31"))
)
parties
parties %>%
  inner_join(parties, join_by(overlaps(start, end, start, end), q < q)) %>%
  select(start.x, end.x, start.y, end.y)
parties %>%
  inner_join(parties, join_by(overlaps(start, end, start, end)))

parties <- tibble(
  q = 1:4,
  party = ymd(c("2022-01-10", "2022-04-04", "2022-07-11", "2022-10-03")),
  start = ymd(c("2022-01-01", "2022-04-04", "2022-07-11", "2022-10-03")),
  end = ymd(c("2022-04-03", "2022-07-10", "2022-10-02", "2022-12-31"))
)

employees %>%
  inner_join(parties, join_by(between(birthday, start, end)), unmatched = "error") %>%
  arrange(birthday)

## 练习
# 没有代码
