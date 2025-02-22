library(tidyverse)
library(repurrrsive)
library(jsonlite)

# Lists-----
x1 <- list(1:4, "a", TRUE)
x1
x2 <- list(a = 1:2, b = 1:3, c = 1:4)
x2
str(x1)
str(x2)
x3 <- list(list(1, 2), list(3, 4))
str(x3)
c(c(1, 2), c(3, 4))
x4 <- c(list(1, 2), list(3, 4))
str(x4)

x5 <- list(1, list(2, list(3, list(4, list(5)))))
str(x5)
View(x5)

df <- tibble(
  x = 1:2,
  y = c("a", "b"),
  z = list(list(1, 2), list(3, 4, 5))
)
df
df %>%
  filter(x == 1)
df %>%
  pull(z) %>%
  str()

data.frame(x = list(1:3, 3:5))
data.frame(
  x = I(list(1:3, 3:5)),
  y = c("1, 2", "3, 4, 5")
)

# 解嵌套----
df1 <- tribble(
  ~x, ~y,
  1, list(a = 11, b = 12),
  2, list(a = 21, b = 22),
  3, list(a = 31, b = 32),
)
df2 <- tribble(
  ~x, ~y,
  1, list(11, 12, 13),
  2, list(21),
  3, list(31, 32),
)

df1 %>%
  unnest_wider(y)
df1 %>%
  unnest_wider(y, names_sep = "_")
df2 %>%
  unnest_longer(y)
df6 <- tribble(
  ~x, ~y,
  "a", list(1, 2),
  "b", list(3),
  "c", list()
)
df6 %>%
  unnest_longer(y, keep_empty = TRUE)

df4 <- tribble(
  ~x, ~y,
  "a", list(1),
  "b", list("a", TRUE, 5)
)
df4 %>%
  unnest_longer(y)

unnest_auto(df1, y)
unnest_auto(df2, y)
unnest_auto(df6, y)
unnest(df4, y)

## 练习
unnest_wider(df2, y)
unnest_wider(df2, y, names_sep = "_")

reprex::reprex({
  library(tidyverse)
  df1 <- tribble(
    ~x, ~y,
    1, list(a = 11, b = 12),
    2, list(a = 21, b = 22),
    3, list(a = 31, b = 32),
  )
  unnest_longer(df1, y)
  unnest_longer(df1, y, indices_include = FALSE)
})
unnest_longer(df1, y)
unnest_longer(df1, y, indices_include = FALSE)

df4 <- tribble(
  ~x, ~y, ~z,
  "a", list("y-a-1", "y-a-2"), list("z-a-1", "z-a-2"),
  "b", list("y-b-1", "y-b-2", "y-b-3"), list("z-b-1", "z-b-2", "z-b-3")
)
df4 %>%
  unnest_longer(c(y, z))

# 案例学习-------
repos <- tibble(json = gh_repos)
repos %>%
  unnest_longer(json) %>%
  unnest_wider(json)

repos %>%
  unnest_longer(json) %>%
  unnest_wider(json) %>%
  names() %>%
  head(10)

repos %>%
  unnest_longer(json) %>%
  unnest_wider(json) %>%
  select(id, full_name, owner, description) %>%
  unnest_wider(owner, names_sep = "_")

chars <- tibble(json = got_chars)
characters <- chars |>
  unnest_wider(json) |>
  select(id, name, gender, culture, born, died, alive)
chars %>%
  unnest_wider(json) %>%
  select(id, where(is.list))
chars %>%
  unnest_wider(json) %>%
  select(id, titles) %>%
  unnest_longer(titles) %>%
  filter(titles != "") %>%
  rename(title = titles)

locations <- gmaps_cities %>%
  unnest_wider(json) %>%
  select(-status) %>%
  unnest_longer(results) %>%
  unnest_wider(results)
locations %>%
  select(city, formatted_address, geometry) %>%
  unnest_wider(geometry) %>%
  unnest_wider(location)
locations %>%
  select(city, formatted_address, geometry) %>%
  unnest_wider(geometry) %>%
  select(!location:viewport) %>%
  unnest_wider(bounds) %>%
  unnest_wider(c(northeast, southwest), names_sep = "_")
locations %>%
  select(city, formatted_address, geometry) %>%
  hoist(
    geometry,
    ne_lat = c("bounds", "northeast", "lat"),
    sw_lat = c("bounds", "southwest", "lat"),
    ne_lng = c("bounds", "northeast", "lng"),
    sw_lng = c("bounds", "southwest", "lng")
  )

## 练习
repos %>%
  unnest_longer(json) %>%
  unnest_wider(json) %>%
  select(created_at) %>%
  arrange(created_at)

repos %>%
  unnest_longer(json) %>%
  unnest_wider(json) %>%
  select(full_name, owner) %>%
  unnest_wider(owner, names_sep = "_") %>%
  select(full_name, owner_login) %>%
  group_by(owner_login) %>%
  summarise(full_name = list(full_name))

repos %>%
  unnest_longer(json) %>%
  unnest_wider(json) %>%
  group_by(owner) %>%
  summarise(full_name = list(full_name))

chars <- tibble(json = got_chars)

chars %>%
  unnest_wider(json) %>%
  select(id, titles) %>%
  unnest_longer(titles) %>%
  filter(titles != "") %>%
  rename(title = titles)

chars %>%
  unnest_wider(json) %>%
  select(id, aliases) %>%
  unnest_longer(aliases) %>%
  filter(aliases != "") %>%
  rename(alias = aliases)

chars %>%
  unnest_wider(json) %>%
  select(id, allegiances) %>%
  unnest_longer(allegiances) %>%
  filter(allegiances != "") %>%
  rename(allegiance = allegiances)

chars %>%
  unnest_wider(json) %>%
  select(id, books) %>%
  unnest_longer(books) %>%
  filter(books != "") %>%
  rename(book = books)

chars %>%
  unnest_wider(json) %>%
  select(id, tvSeries) %>%
  unnest_longer(tvSeries) %>%
  filter(tvSeries != "") %>%
  rename(book = tvSeries)

tibble(json = got_chars) |>
  unnest_wider(json) |>
  select(id, where(is.list)) |>
  pivot_longer(
    where(is.list),
    names_to = "name",
    values_to = "value"
  ) |>
  unnest_longer(value)

gmaps_cities %>%
  unnest_wider(json) %>%
  select(-status) %>%
  unnest_longer(results) %>%
  unnest_wider(results) %>%
  unnest_longer(address_components) %>%
  unnest_wider(address_components, names_sep = "_") %>%
  unnest_longer(address_components_types)

# JSON-----
gh_users_json()
gh_users2 <- read_json(gh_users_json())
identical(gh_users, gh_users2)

str(parse_json("1"))
str(parse_json("[1,2,3]"))
str(parse_json('{"x":[1,2,3]}'))

json <- '[
  {"name": "John", "age": 34},
  {"name": "Susan", "age": 27}
]'
df <- tibble(json = parse_json(json))
df
df %>%
  unnest_wider(json)

json <- '{
  "status": "OK",
  "results": [
    {"name": "John", "age": 34},
    {"name": "Susan", "age": 27}
 ]
}
'
df <- tibble(json = list(parse_json(json)))
df
df %>%
  unnest_wider(json) %>%
  unnest_longer(results) %>%
  unnest_wider(results)

df <- tibble(results = parse_json(json)$results)
df %>% unnest_wider(results)
## 练习
json_col <- parse_json('
  {
    "x": ["a", "x", "z"],
    "y": [10, null, 3]
  }
')
json_row <- parse_json('
  [
    {"x": "a", "y": 10},
    {"x": "x", "y": null},
    {"x": "z", "y": 3}
  ]
')

df_col <- tibble(json = list(json_col))
df_row <- tibble(json = json_row)

df_col %>%
  unnest_wider(json) %>%
  unnest_longer(c(x, y))

df_row %>%
  unnest_wider(json)
