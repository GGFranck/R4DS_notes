library(tidyverse)
library(arrow)
library(dbplyr)
library(duckdb)

setwd("d:\\Data\\知识库\\R语言基础\\R4DS学习笔记\\0522 arrow处理大数据.assets")

# 数据获取-----
dir.create("data", showWarnings = FALSE)

curl::multi_download(
  "https://r4ds.s3.us-west-2.amazonaws.com/seattle-library-checkouts.csv",
  "data/seattle-library-checkouts.csv",
  resume = TRUE
)


# 打开数据-----
seattle_csv <- open_dataset(
  sources = "data/seattle-library-checkouts.csv",
  col_types = schema(ISBN = string()),
  format = "csv"
)

seattle_csv

seattle_csv %>% glimpse()

seattle_csv %>%
  group_by(CheckoutYear) %>%
  summarise(Checkouts = sum(Checkouts)) %>%
  arrange(Checkouts) %>%
  collect()

# parquet格式------
pq_path <- "data/seattle-library-checkouts"
seattle_csv %>%
  group_by(CheckoutYear) %>%
  write_dataset(path = pq_path, format = "parquet")

tibble(
  files = list.files(pq_path, recursive = TRUE),
  size_MB = file.size(file.path(pq_path, files)) / 1024^2
)

seattle_pq <- open_dataset(pq_path)
query <- seattle_pq %>%
  filter(CheckoutYear >= 2018, MaterialType == "BOOK") %>%
  group_by(CheckoutYear, CheckoutMonth) %>%
  summarise(TotalCheckouts = sum(Checkouts)) %>%
  arrange(CheckoutYear, CheckoutMonth)
query

query %>% collect()
?acero

seattle_csv %>%
  filter(CheckoutYear == 2021, MaterialType == "BOOK") %>%
  group_by(CheckoutMonth) %>%
  summarise(TotalCheckouts = sum(Checkouts)) %>%
  arrange(desc(CheckoutMonth)) %>%
  collect() %>%
  system.time()

seattle_pq %>%
  filter(CheckoutYear == 2021, MaterialType == "BOOK") %>%
  group_by(CheckoutMonth) %>%
  summarise(TotalCheckouts = sum(Checkouts)) %>%
  arrange(desc(CheckoutMonth)) %>%
  collect() %>%
  system.time()

seattle_pq %>%
  to_duckdb() %>%
  filter(CheckoutYear >= 2018, MaterialType == "BOOK") %>%
  group_by(CheckoutYear) %>%
  summarise(TotalCheckouts = sum(Checkouts)) %>%
  arrange(desc(CheckoutYear)) %>%
  collect()

seattle_pq %>%
  filter(Creator != "") %>%
  head(5) %>%
  collect()

seattle_pq %>%
  filter(MaterialType == "BOOK") %>%
  filter(!str_detect(Title, "^<|^Unc")) %>%
  group_by(CheckoutYear, Title) %>%
  summarise(TotalCheckouts = sum(Checkouts)) %>%
  arrange(CheckoutYear, desc(TotalCheckouts)) %>%
  collect() %>%
  slice_head(n = 1)

seattle_pq %>%
  filter(MaterialType == "BOOK") %>%
  filter(!str_detect(Title, "^<|^Unc")) %>%
  filter(Creator != "") %>%
  distinct(Title, Creator) %>%
  count(Creator, sort = TRUE) %>%
  head(10) %>%
  collect()

type_var <- seattle_pq %>%
  filter(MaterialType %in% c("BOOK", "EBOOK")) %>%
  group_by(CheckoutYear, MaterialType) %>%
  summarise(TotalCheckouts = sum(Checkouts)) %>%
  arrange(CheckoutYear, MaterialType) %>%
  collect()
type_var %>%
  ggplot(aes(x = CheckoutYear, y = TotalCheckouts, color = MaterialType)) +
  geom_line() +
  scale_x_continuous(breaks = seq(2005, 2022, 1))
