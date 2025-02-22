library(nycflights13)
library(tidyverse)

flights |>
  filter(dest == "IAH") |> 
  group_by(year, month, day) |> 
  summarize(
    arr_delay = mean(arr_delay, na.rm = TRUE)
  )
#行操作----
flights %>% 
  filter(dep_delay > 120)

flights |> 
  filter(month == 1 & day == 1)

flights |> 
  filter(month == 1 | month == 2)

flights |> 
  filter(month %in% c(1, 2))

flights %>% 
  arrange(year,month,day,dep_time)
flights %>% 
  arrange(desc(dep_time))

flights %>% distinct() %>% dim()
flights %>% distinct(origin,dest)
flights %>% count(origin,dest,sort = T)
#练习1----
flights %>% filter(arr_delay >= 120)
flights %>% filter(dest == 'IAH'| dest == 'HOU')
flights %>% filter(carrier %in% c('UA','AA','DL'))
flights %>% filter(arr_delay > 120 & dep_delay<=0)
flights %>% filter(dep_delay > 60 & arr_delay < 30)

flights %>% arrange(desc(dep_delay))
flights %>% arrange(desc(dep_time))
flights %>% arrange(air_time)

flights %>% distinct(year,month,day,tailnum) %>% count(tailnum,sort = T)
flights$distance %>% aggregate(by=list(flights$tailnum),FUN = 'sum') %>% arrange(x) %>% head(1)
flights$distance %>% 
  aggregate(by=list(flights$tailnum),FUN = 'sum') %>% 
  arrange(x) %>% 
  tail(1)

flights %>% 
  group_by(tailnum) %>% 
  summarise(sum_distance = sum(distance)) %>% 
  arrange(sum_distance) %>% 
  head(1)
#列操作---------
flights %>% mutate(
  gain = dep_delay - arr_delay,
  speed = distance / air_time * 60,
  .after = day
)

flights |> 
  mutate(
    gain = dep_delay - arr_delay,
    hours = air_time / 60,
    gain_per_hour = gain / hours,
    .keep = "used"
  )

flights %>% 
  select(year,month,day)
flights %>% 
  select(year:day)
flights %>% 
  select(!year:day)

flights %>% 
  select(where(is.character))

flights %>% 
  select(starts_with('arr'))
flights %>% 
  select(ends_with('delay'))
flights %>% 
  select(contains('time'))
matrix(NA,ncol = 5,nrow = 10) %>% 
  as.data.frame() %>% 
  select(num_range('V',1:3))
flights %>% 
  select(matches('^dep'))
flights |> 
  select(tailnum = tailnum)

flights %>% 
  relocate(time_hour,air_time)
flights %>% 
  relocate(year:dep_time,.after = time_hour)
flights %>% 
  relocate(starts_with('arr'),.before = dep_time)

#练习2------
flights %>% 
  select(dep_time,sched_dep_time,dep_delay) %>% 
  mutate(dep_delay2 = dep_time - sched_dep_time)

flights %>% 
  select(starts_with('arr') | starts_with('dep'))

flights %>% 
  select(all_of(variables))
flights %>% 
  select(!any_of(variables))

flights |> select(contains("Time"),ignore.case = F)#报错就成功了。

flights %>% rename(air_time_min = air_time) %>% relocate(air_time_min)

flights |> 
  select(tailnum,arr_delay) %>% 
  arrange(arr_delay)
#分组-----
flights %>% 
  group_by(month) %>% 
  summarise(
    avg_delay = mean(dep_delay,na.rm = T)
  )
flights %>% 
  group_by(month) %>% 
  slice_max(dep_delay, n = 1, with_ties = F) %>% 
  relocate(dep_delay) %>% 
  view()

daily <- flights |>  
  group_by(year, month, day)

daily_flights <- daily |> 
  summarize(n = n())

daily_flights <- daily |> 
  summarize(
    n = n(), 
    .groups = "drop_last"
  )

daily %>% 
  ungroup()

flights %>% 
  summarise(
    delay = mean(dep_delay, na.rm = T),
    n = n(),
    .by = month
  )
flights %>% 
  group_by(month) %>% 
  summarise(
    delay = mean(dep_delay, na.rm = T),
    n = n(),
  )
flights |> 
  summarize(
    delay = mean(dep_delay, na.rm = TRUE), 
    n = n(),
    .by = c(origin, dest)
  )
#练习3----
flights %>% 
  group_by(carrier) %>% 
  summarise(
    mean_dep_delay = mean(dep_delay,na.rm = T),
    mean_arr_dely = mean(arr_delay, na.rm = T)) %>% 
  arrange(desc(mean_dep_delay))
flights |> group_by(carrier, dest) |> summarize(n = n())

flights %>% 
  group_by(dest) %>% 
  slice_max(dep_delay) %>% 
  relocate(tailnum,dest)

ggplot(flights,aes(x = dep_delay))+
  geom_histogram(bins = 10)

mydata <- flights %>% 
  group_by(hour) %>% 
  summarise(
    mean_dep_delay = mean(dep_delay,na.rm = T),
    sd_dep_delay = sd(dep_delay,na.rm = T)) %>% 
  na.omit()

ggplot(mydata)+
  geom_line(aes(x = hour,y=mean_dep_delay))+
  geom_point(aes(x = hour,y = mean_dep_delay))+
  geom_errorbar(aes(x= hour,ymin = mean_dep_delay-sd_dep_delay,ymax = mean_dep_delay+sd_dep_delay))

flights %>% 
  group_by(month) %>% 
  slice_min(dep_delay,n=-10) %>% 
  relocate(dep_delay)

flights %>% 
  group_by(carrier,month) %>% 
  count()

flights %>% 
  count(carrier,month,sort = T) %>% 
  arrange(n)

df <- tibble(
  x = 1:3,
  y = c("a", "b", "a", "a", "b"),
  z = c("K", "K", "L", "L", "K")
)

df %>% 
  arrange(y)
df |>
  group_by(y) |>
  summarize(mean_x = mean(x))
