library(tidyverse)
library(readxl)
library(writexl)
library(openxlsx)

setwd("D:/Data/知识库/R语言基础/R4DS学习笔记/0520 电子表格spreadsheet.assets/")
# Excel-----
students <- read_excel("./students.xlsx")
students
read_excel(
  "./students.xlsx",
  col_names = c("student_id", "full_name", "favourite_food", "meal_plan", "age")
)
read_excel(
  "./students.xlsx",
  col_names = c("student_id", "full_name", "favourite_food", "meal_plan", "age"),
  skip = 1
)
janitor::clean_names(students)
read_excel(
  "./students.xlsx",
  col_names = c("student_id", "full_name", "favourite_food", "meal_plan", "age"),
  skip = 1,
  na = c("", "N/A")
)
read_excel(
  "./students.xlsx",
  col_names = c("student_id", "full_name", "favourite_food", "meal_plan", "age"),
  skip = 1,
  na = c("", "N/A"),
  col_types = c("numeric", "text", "text", "text", "numeric")
)
students <- read_excel(
  "./students.xlsx",
  col_names = c("student_id", "full_name", "favourite_food", "meal_plan", "age"),
  skip = 1,
  na = c("", "N/A"),
  col_types = c("numeric", "text", "text", "text", "text")
)
students %>%
  mutate(
    age = if_else(age == "five", "5", age),
    age = parse_number(age)
  )

students[students == "five"] <- "5"
students$age <- as.numeric(students$age)
students

read_excel("./penguins.xlsx", sheet = "Torgersen Island")
penguins_torgersen <- read_excel("./penguins.xlsx", sheet = "Torgersen Island", na = "NA")
penguins_torgersen

excel_sheets("./penguins.xlsx")
penguins_biscoe <- read_excel("./penguins.xlsx", sheet = "Biscoe Island", na = "NA")
penguins_dream <- read_excel("./penguins.xlsx", sheet = "Dream Island", na = "NA")
dim(penguins_torgersen)
dim(penguins_biscoe)
dim(penguins_dream)

penguins <- bind_rows(penguins_torgersen, penguins_biscoe, penguins_dream)
penguins

deaths_path <- readxl_example("deaths.xlsx")
deaths <- read_excel(deaths_path)
deaths

read_excel(deaths_path, range = "A5:F15")

bake_sale <- tibble(
  item = factor(c("brownie", "cupcake", "cookie")),
  quantity = c(10, 5, 8)
)
bake_sale
write_xlsx(bake_sale, "./bake-sale.xlsx")

read_xlsx("./bake-sale.xlsx")

## 练习-----
survey <- read_excel("./survey.xlsx", na = c("", "N/A"))
survey <- survey %>%
  mutate(
    n_pets = if_else(n_pets == "two", "2", n_pets),
    n_pets = parse_number(n_pets)
  )
survey

roster <- read_excel("./roster.xlsx")
roster %>%
  fill(everything())

sales <- read_excel("./sales.xlsx", skip = 2, col_names = c("id", "n"))
sales
sales %>%
  mutate(brand = if_else(n == "n", id, NA)) %>%
  fill(brand) %>%
  filter(!n == "n") %>%
  relocate(brand) %>%
  mutate(
    id = parse_number(id),
    n = parse_number(n)
  )

write.xlsx(bake_sale, "bake-sale2.xlsx")
bake_sale

read_xls("./roster.xlsx")
