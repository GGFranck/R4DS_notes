library(tidyverse)
library(ggplot2)
library(dplyr)
library(networkD3)
library(ggalluvial)
# 因子：基础-------------
x1 <- c("Dec", "Apr", "Jan", "Mar")
sort(x1)
x2 <- c("Dec", "Apr", "Jam", "Mar")

month_levels <- c(
  "Jan", "Feb", "Mar", "Apr", "May", "Jun",
  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
)
y1 <- factor(x1, levels = month_levels)
y1
sort(y1)
y2 <- factor(x2, levels = month_levels)
y2

fct(x2, levels = month_levels)
factor(x1)
fct(x1)
levels(y1)

csv <- "
month,value
Jan,12
Feb,56
Mar,12"
df <- read_csv(csv, col_types = cols(month = col_factor(month_levels)))

# 综合社会调查------------
gss_cat %>%
  count(race)

# x轴顺序倒转
gss_cat %>%
  count(rincome) %>%
  filter(str_detect(rincome, "\\d")) %>%
  ggplot(aes(fct_rev(rincome), n)) +
  geom_bar(stat = "identity") +
  coord_flip()

gss_cat %>%
  count(relig, sort = TRUE)
gss_cat %>%
  count(partyid, sort = TRUE)
gss_cat %>%
  filter(denom != "Not applicable") %>%
  count(relig, denom) %>%
  arrange(desc(denom), desc(n))

links <- gss_cat %>%
  count(relig, denom)
nodes <- links[, 1:2] %>%
  as.matrix() %>%
  as.character() %>%
  unique() %>%
  data.frame(name = .)
links$IDsource <- match(links$relig, nodes$name) - 1 # 计算位置索引
links$IDtarget <- match(links$denom, nodes$name) - 1
links
p <- sankeyNetwork(
  Links = links,
  Nodes = nodes,
  Source = "IDsource",
  Target = "IDtarget",
  Value = "n",
  NodeID = "name",
  sinksRight = FALSE
)

links %>%
  filter(!str_detect(denom, "No|Don")) %>%
  ggplot(aes(
    axis1 = relig,
    axis2 = denom,
    y = n
  )) +
  geom_alluvium(aes(fill = relig)) +
  geom_stratum() +
  geom_text(stat = "stratum", aes(label = after_stat(stratum))) +
  theme_void()
# ggsave("sankey.png")

# 调整因子顺序-----
relig_summary <- gss_cat %>%
  group_by(relig) %>%
  summarise(
    tvhours = mean(tvhours, na.rm = TRUE),
    n = n()
  )

ggplot(relig_summary, aes(x = tvhours, y = relig)) +
  geom_point()

ggplot(relig_summary, aes(x = tvhours, y = fct_reorder(relig, tvhours))) +
  geom_point()

relig_summary %>%
  mutate(relig = fct_reorder(relig, tvhours)) %>%
  ggplot(aes(tvhours, relig)) +
  geom_point()

rincome_summary <- gss_cat %>%
  group_by(rincome) %>%
  summarise(
    age = mean(age, na.rm = TRUE),
    n = n()
  )
ggplot(rincome_summary, aes(x = age, y = fct_reorder(rincome, age))) +
  geom_point()
levels(rincome_summary$rincome)
ggplot(rincome_summary, aes(x = age, y = fct_relevel(rincome, c("Not applicable", "Refused")))) +
  geom_point()

by_age <- gss_cat %>%
  filter(!is.na(age)) %>%
  count(age, marital) %>%
  group_by(age) %>%
  mutate(prop = n / sum(n))

ggplot(by_age, aes(x = age, y = prop, color = marital)) +
  geom_line() +
  scale_color_brewer(palette = "Set1")

ggplot(by_age, aes(x = age, y = prop, color = fct_reorder2(marital, age, prop))) +
  geom_line() +
  scale_color_brewer(palette = "Set1")

gss_cat %>%
  mutate(marital = marital %>% fct_infreq() %>% fct_rev()) %>%
  ggplot(aes(x = marital)) +
  geom_bar()

## 练习
hist(gss_cat$tvhours, breaks = 40)
qqnorm(gss_cat$tvhours)
qqline(gss_cat$tvhours)
# shapiro.test(gss_cat$tvhours)
ks.test(gss_cat$tvhours, pnorm)


for (i in 1:ncol(gss_cat)) {
  if (class(as.data.frame(gss_cat)[, i]) == "factor") {
    print(as.data.frame(gss_cat)[, i] %>% levels())
  }
}
# 修改因子的levels
new <- gss_cat |>
  mutate(
    partyid = fct_recode(partyid,
      "Republican, strong"    = "Strong republican",
      "Republican, weak"      = "Not str republican",
      "Independent, near rep" = "Ind,near rep",
      "Independent, near dem" = "Ind,near dem",
      "Democrat, weak"        = "Not str democrat",
      "Democrat, strong"      = "Strong democrat"
    )
  )

new$partyid %>% levels()
gss_cat$partyid %>% levels()

a <- factor(3:5, levels = 3:5, labels = 5:7)
as.numeric(a)

new <- gss_cat %>%
  mutate(relig = fct_lump_n(relig, n = 10))
gss_cat$relig %>% levels()
new$relig %>% levels()

c(
  rep(1, 1),
  rep(2, 2),
  rep(3, 3),
  rep(4, 4),
  rep(5, 5)
) %>%
  factor() %>%
  fct_lump_min(3) %>%
  levels()
## 练习
gss_cat() %>%
  mutate(partyid_2 = case_when(
    str_detect(partyid, "nd") ~ "Independent",
    str_detect(partyid, "em") ~ "Democrat",
    str_detect(partyid, "ep") ~ "Republican",
  )) %>%
  group_by(year) %>%
  count(partyid_2) %>%
  mutate(prop = n / sum(n)) %>%
  filter(!is.na(partyid_2)) %>%
  ggplot(aes(x = year, y = prop, color = fct_reorder2(partyid_2, year, prop))) +
  geom_line() +
  labs(x = "Year", y = "Proportion", color = "Party ID")

my_levels <- levels(gss_cat$rincome)
my_data <- gss_cat %>%
  mutate(
    rincome = fct_collapse(
      rincome,
      "other" = my_levels[!str_detect(my_levels, "\\d")],
      "$20000+" = my_levels[7:15],
      "$10000+" = my_levels[6:7],
      "$10000-" = my_levels[4:5]
    )
  )
my_data %>% count(rincome)

# 有序分类变量------
ordered(factor(c("2", "3", "1")))
