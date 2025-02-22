library(DBI)
library(dplyr)
library(tidyverse)

setwd("D:\\Data\\知识库\\R语言基础\\R4DS学习笔记\\0521 数据库.assets\\")

# 连接到数据库--------
# con <- DBI::dbConnect(
#   RMariaDB::MariaDB(),
#   username = "foo"
# )
# con <- DBI::dbConnect(
#   RPostgres::Postgres(),
#   hostname = "databases.mycompany.com",
#   port = 1234
# )

con <- DBI::dbConnect(duckdb::duckdb())
dbDisconnect(con, shutdown = TRUE)
con <- DBI::dbConnect(duckdb::duckdb(), dbdir = "duckdb")

dbWriteTable(con, "mpg", ggplot2::mpg)
dbWriteTable(con, "diamonds", ggplot2::diamonds)

dbListTables(con)
con %>%
  dbReadTable("diamonds") %>%
  as_tibble()

sql <- "
SELECT carat, cut, clarity, color, price
FROM diamonds
WHERE price > 15000
"
as_tibble(dbGetQuery(con, sql))

diamonds %>%
  select(carat, cut, clarity, color, price) %>%
  filter(price > 15000)

# dbplyr基础------
library(dbplyr)
diamonds_db <- tbl(con, "diamonds")
diamonds_db

diamonds_db <- tbl(con, in_schema("sales", "diamonds"))
diamonds_db <- tbl(con, in_catalog("north_america", "sales", "diamonds"))
diamonds_db <- tbl(con, sql("SELECT * FROM diamonds"))

big_diamonds_db <- diamonds_db %>%
  filter(price > 15000) %>%
  select(carat:clarity, price)
big_diamonds_db
big_diamonds_db %>% show_query()
big_diamonds <- big_diamonds_db %>% collect()
big_diamonds

# SQL---------
dbplyr::copy_nycflights13(con)
dbListTables(con)
flights <- tbl(con, "flights")
planes <- tbl(con, "planes")

flights %>% show_query()
planes %>% show_query()

flights %>%
  filter(dest == "IAH") %>%
  arrange(dep_delay) %>%
  show_query()

flights %>%
  group_by(dest) %>%
  summarise(dep_delay = mean(dep_delay, na.rm = TRUE)) %>%
  show_query()

planes %>%
  select(tailnum, type, manufacturer, model, year) %>%
  show_query()

planes %>%
  select(tailnum, type, manufacturer, model, year) %>%
  rename(year_built = year) %>%
  show_query()

planes %>%
  select(tailnum, type, manufacturer, model, year) %>%
  relocate(manufacturer, model, .before = type) %>%
  show_query()

flights %>%
  mutate(
    speed = distance / (air_time / 60)
  ) %>%
  show_query()

diamonds_db %>%
  group_by(cut) %>%
  summarise(
    n = n(), avg_price = mean(price, na.rm = TRUE)
  ) %>%
  show_query()

flights %>%
  filter(dest == "IAH" | dest == "HOU") %>%
  show_query()
flights %>%
  filter(arr_delay > 0 & arr_delay < 20) %>%
  show_query()
flights %>%
  filter(dest %in% c("IAH", "HOU")) %>%
  show_query()

flights %>%
  group_by(dest) %>%
  summarise(delay = mean(arr_delay))

flights %>%
  filter(!is.na(dep_delay)) %>%
  show_query()

dbGetQuery(con, "SELECT * FROM flights WHERE dep_delay IS NOT NULL") %>% as_tibble()

diamonds_db %>%
  group_by(cut) %>%
  summarise(n = n()) %>%
  filter(n > 100) %>%
  show_query()

flights %>%
  arrange(year, month, day, desc(dep_delay)) %>%
  show_query()

flights %>%
  mutate(
    year1 = year + 1,
    year2 = year1 + 1
  ) %>%
  show_query()

flights %>%
  mutate(year1 = year + 1) %>%
  filter(year1 == 2014) %>%
  show_query()

flights %>%
  left_join(planes %>% rename(year_built = year), by = "tailnum") %>%
  show_query()
## 练习
flights %>%
  distinct(carrier) %>%
  head(20) %>%
  show_query()

flights %>%
  filter(dep_delay < arr_delay) %>%
  show_query()

flights %>%
  mutate(speed = distance / (air_time / 60)) %>%
  show_query()

flights |>
  group_by(year, month, day) |>
  mutate(
    mean = mean(arr_delay, na.rm = TRUE),
  )
