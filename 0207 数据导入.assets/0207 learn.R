library(tidyverse)
#------
students <- read_csv('./students.csv')
#rm(students)
#students <- read_csv("https://pos.it/r4ds-students-csv")

students <- read_csv('./students.csv',na = c('N/A',''))
students %>% rename(student_id = `Student ID`,
                    full_name = `Full Name`)
students %>% janitor::clean_names()
table(students$mealPlan)
students %>% mutate(mealPlan = factor(mealPlan)) %>% glimpse()

students <- students |>
  janitor::clean_names() |>
  mutate(
    meal_plan = factor(meal_plan),
    age = parse_number(if_else(age == "five", "5", age))
  );students
#excercise 01-----
read_delim(
  'a|b|c
  1|2|3
  4|5|6')

read_csv("x,y\n1,'a,b'")

read_delim("a,b\n1,2,3\n4,5,6",delim = ',')
read_csv("a,b,c\n1,2\n1,2,3,4")
read_csv("a,b\n\"1")
read_csv("a,b\n1,2\na,b")
read_csv("a;b\n1;3")

annoying <- tibble(
  `1` = 1:10,
  `2` = `1` * 2 + rnorm(length(`1`))
)

annoying %>% select(1)
annoying %>% select(`1`)
ggplot(annoying,aes(x = `1`,y = `2`))+
  geom_point()
annoying %>% mutate(`3` = `2`/`1`)
annoying %>% rename(one = `1`,
                    two = `2`)
#列的变量类型-----
read_csv(
  'a,b,c
  T,F,T'
)

simple_csv <- "
  x
  10
  .
  20
  30"
read_csv(simple_csv)
df <- read_csv(
  simple_csv, 
  col_types = list(x = col_double())
)
read_csv(simple_csv, na = ".")

another_csv <- "
x,y,z
1,2,3"

read_csv(
  another_csv,
  col_types = cols(.default = col_character())
)

read_csv(
  another_csv,
  col_types = cols_only(x = col_character())
)

#多文件读取数据-----
sales_files <- c(
  "https://pos.it/r4ds-01-sales",
  "https://pos.it/r4ds-02-sales",
  "https://pos.it/r4ds-03-sales"
)
read_csv(sales_files, id = "file")
#保存数据框文件
table1
write_csv(table1,'tabel1.csv')
library(arrow)
#read_parquet()
#write_parquet()
#数据录入------
tibble(
  x = c(1,2,5),
  y = c("h","m","g"),
  z = c(0.08, 0.83, 0.60)
)

tribble(
  ~x, ~y, ~z,
  1, "h", 0.08,
  2, "m", 0.83,
  5, "g", 0.60
)
