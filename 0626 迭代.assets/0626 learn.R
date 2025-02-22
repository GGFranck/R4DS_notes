library(tidyverse)
library(dplyr)
library(lubridate)
library(readxl)
library(writexl)
library(purrr)
# 修改多列-----
df <- tibble(
  a = rnorm(10),
  b = rnorm(10),
  c = rnorm(10),
  d = rnorm(10)
)

df %>%
  summarise(
    n = n(),
    a = median(a),
    b = median(b),
    c = median(c),
    d = median(b)
  )

df %>%
  summarise(
    n = n(),
    across(a:d, median, .names = "{.col}_median")
  )
?across

df <- tibble(
  grp = sample(2, 10, replace = TRUE),
  a = rnorm(10),
  b = rnorm(10),
  c = rnorm(10),
  d = rnorm(10)
)
df %>%
  group_by(grp) %>%
  summarise(across(everything(), median))

df %>%
  group_by(grp) %>%
  summarise(across(everything(), median()))

rnorm_na <- function(n, n_na, mean = 0, sd = 1) {
  sample(c(rnorm(n - n_na, mean = mean, sd = sd), rep(NA, n_na)))
}
df_miss <- tibble(
  a = rnorm_na(5, 1),
  b = rnorm_na(5, 1),
  c = rnorm_na(5, 2),
  d = rnorm(5)
)
df_miss %>%
  summarise(
    across(a:d, median),
    n = n()
  )
df_miss %>%
  summarise(
    across(a:d, function(x) median(x, na.rm = TRUE)),
  )

df_miss %>%
  summarise(
    across(a:d, \(x) median(x, na.rm = TRUE))
  )

df_miss %>%
  summarise(
    across(a:d, list(
      median = \(x) median(x, na.rm = TRUE),
      n_miss = \(x) sum(is.na(x))
    )),
    n = n()
  ) %>%
  pivot_longer(
    cols = !n,
    names_to = c("name", "stat"),
    values_to = "value",
    names_sep = "_"
  )

df_miss %>%
  mutate(
    across(a:d, \(x) coalesce(x, 0))
  )
df_miss %>%
  mutate(
    across(a:d, \(x) coalesce(x, 0), .names = "{.col}_na_zero")
  )

df_miss %>% filter(if_any(a:d, is.na))
df_miss %>% filter(if_all(a:d, is.na))

expand_dates <- function(df) {
  df %>%
    mutate(
      across(where(is.Date), list(year = year, month = month, day = day))
    )
}
df_date <- tibble(
  name = c("Amy", "Bob"),
  date = ymd(c("2009-08-03", "2010-01-16"))
)
df_date %>% expand_dates()

summarise_means <- function(df, summary_vars = where(is.numeric)) {
  df %>%
    summarise(
      across({{ summary_vars }}, \(x) mean(x, na.rm = TRUE)),
      n = n(),
      .groups = "drop"
    )
}
diamonds %>%
  group_by(cut) %>%
  summarise_means()
diamonds %>%
  group_by(cut) %>%
  summarise_means(c(carat, x:z))

df <- tibble(
  a = rnorm(10),
  b = rnorm(10),
  c = rnorm(10),
  d = rnorm(10)
)
df %>%
  summarise(across(a:d, list(mean = mean, median = median)))
df %>%
  pivot_longer(a:d) %>%
  group_by(name) %>%
  summarise(
    median = median(value),
    mean = mean(value)
  ) %>%
  pivot_wider(
    names_from = name,
    values_from = c(median, mean),
    names_vary = "slowest",
    names_glue = "{name}_{.value}"
  )

df_paired <- tibble(
  a_val = rnorm(10),
  a_wts = runif(10),
  b_val = rnorm(10),
  b_wts = runif(10),
  c_val = rnorm(10),
  c_wts = runif(10),
  d_val = rnorm(10),
  d_wts = runif(10)
)
df_long <- df_paired |>
  pivot_longer(
    everything(),
    names_to = c("group", ".value"),
    names_sep = "_"
  )
df_long
df_long %>%
  group_by(group) %>%
  summarise(mean = weighted.mean(val, wts))

## 练习
palmerpenguins::penguins %>%
  summarise(across(everything(), \(x) length(unique(x))))

mtcars %>%
  as_tibble() %>%
  summarise(across(everything(), mean))

diamonds %>%
  group_by(cut, clarity, color) %>%
  summarise(
    across(where(is.numeric), mean),
    n = n()
  )

df <- tibble(
  a = rnorm(10),
  b = rnorm(10),
  c = rnorm(10),
  d = rnorm(10)
)
df %>%
  summarise(across(everything(), list(mean, median)))

expand_dates <- function(df) {
  df %>%
    mutate(
      across(where(is.Date), list(year = year, month = month, day = day))
    )
}
df_date <- tibble(
  name = c("Amy", "Bob"),
  date = ymd(c("2009-08-03", "2010-01-16"))
)
df_date %>% expand_dates()

expand_dates <- function(df, date_var = where(is.Date)) {
  df %>%
    mutate(
      across({{ date_var }}, list(year = year, month = month, day = day))
    ) %>%
    select(-{{ date_var }})
}
expand_dates <- function(df) {
  df %>%
    mutate(
      across(where(is.Date), list(year = year, month = month, day = day))
    ) %>%
    select(-where(is.Date))
}
df_date <- tibble(
  name = c("Amy", "Bob"),
  date = ymd(c("2009-08-03", "2010-01-16"))
)
df_date %>% expand_dates()

show_missing <- function(df, group_vars, summary_vars = everything()) {
  df |>
    group_by(pick({{ group_vars }})) |>
    summarize(
      across({{ summary_vars }}, \(x) sum(is.na(x))),
      .groups = "drop"
    ) |>
    select(where(\(x) any(x > 0)))
}
nycflights13::flights |> show_missing(c(year, month, day))

# 读取多文件-----
setwd("D:/Data/知识库/R语言基础/R4DS学习笔记/0626 迭代.assets")
for (i in 1:5) {
  matrix(rnorm(20), ncol = 5) %>%
    as_tibble() %>%
    write_xlsx(str_glue("data/data{i}.xlsx"))
}

pathes <- list.files("data/", pattern = "[.]xlsx$", full.names = TRUE)
pathes

files <- list(
  read_excel(pathes[1]),
  read_excel(pathes[2]),
  read_excel(pathes[3]),
  read_excel(pathes[4]),
  read_excel(pathes[5])
)
files[[3]]

rm(files)
files <- map(pathes, read_xlsx)
files[[3]]

list_rbind(files)

pathes %>%
  map(read_xlsx) %>%
  list_rbind()

pathes %>%
  map(\(path) read_xlsx(path, n_max = 1)) %>%
  list_rbind()

pathes %>% set_names(basename)

files <- pathes %>%
  set_names(basename) %>%
  map(read_xlsx)
files <- list(
  "data1.xlsx" = read_excel(pathes[1]),
  "data2.xlsx" = read_excel(pathes[2]),
  "data3.xlsx" = read_excel(pathes[3]),
  "data4.xlsx" = read_excel(pathes[4]),
  "data5.xlsx" = read_excel(pathes[5])
)
files[["data2.xlsx"]]

files <- pathes %>%
  set_names(basename) %>%
  map(read_xlsx) %>%
  list_rbind(names_to = "file") %>%
  mutate(number = parse_number(file), .before = 1)
files

write_csv(files, "all.csv")

df_types <- function(df) {
  tibble(
    col_name = names(df),
    col_type = map_chr(df, vctrs::vec_ptype_full),
    n_miss = map_int(df, \(x) sum(is.na(x)))
  )
}
df_types(files)

pathes %>%
  set_names(basename) %>%
  map(read_xlsx) %>%
  map(df_types) %>%
  list_rbind(names_to = "file") %>%
  select(-n_miss) %>%
  pivot_wider(
    names_from = col_name,
    values_from = col_type
  )

a <- list(1, 2, 3, "wow")
a %>% map(~ .x + 1)
a %>% map(possibly(~ .x + 1, NULL))
a %>%
  map(possibly(~ .x + 1, NULL)) %>%
  unlist()

# 保存多个输出-------
dir.create("data2", showWarnings = FALSE)
for (i in 1:5) {
  matrix(rnorm(20), ncol = 5) %>%
    as_tibble() %>%
    write_csv(str_glue("data2/data{i}.csv"))
}
paths <- list.files("data2", full.names = TRUE)
con <- DBI::dbConnect(duckdb::duckdb())
duckdb::duckdb_read_csv(con, "paths", paths)
con %>%
  DBI::dbReadTable("paths") %>%
  as_tibble()
DBI::dbDisconnect(con, shutdown = TRUE)

template <- read_xlsx("data/data1.xlsx")
template$file <- "data1.xlsx"
template
con <- DBI::dbConnect(duckdb::duckdb())
DBI::dbCreateTable(con, "mydata", template)
tbl(con, "mydata")
DBI::dbDisconnect(con, shutdown = TRUE)

append_file <- function(path) {
  df <- read_xlsx(path)
  df$file <- basename(path)

  DBI::dbAppendTable(con, "mydata", df)
}
pathes %>% map(append_file)
pathes %>% walk(append_file)
tbl(con, "mydata")

by_clarity <- diamonds %>%
  group_nest(clarity)

by_clarity %>%
  unnest(data)

by_clarity$data[[2]]

by_clarity <- by_clarity %>%
  mutate(path = str_glue("diamonds-{clarity}.csv"))

walk2(by_clarity$data, by_clarity$path, write_csv)

carat_histogram <- function(df) {
  ggplot(df, aes(x = carat)) +
    geom_histogram(binwidth = 0.1)
}
carat_histogram(by_clarity$data[[1]])

by_clarity <- by_clarity %>%
  mutate(
    plot = map(data, carat_histogram),
    path = str_glue("clarity-{clarity}.png")
  )
by_clarity
walk2(
  by_clarity$path,
  by_clarity$plot,
  \(path, plot) ggsave(path, plot, width = 6, height = 6)
)
