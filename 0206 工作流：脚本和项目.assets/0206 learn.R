library(dplyr)
library(nycflights13)

not_cancelled <- flights |> 
  filter(!is.na(dep_delay), !is.na(arr_delay))

not_cancelled |> 
  group_by(year, month, day) |> 
  summarize(mean = mean(dep_delay))

3 == NA

3 == NA
3 != NA
if(!is.na(3)){print(2)}
if(3 != NA){print(2)}
