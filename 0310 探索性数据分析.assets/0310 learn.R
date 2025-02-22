library(tidyverse)
library(ggplot2)

ggplot(diamonds, aes(x = y)) +
  geom_histogram() +
  coord_cartesian(ylim = c(0, 50))

ggplot(diamonds, aes(x = y)) +
  geom_histogram() +
  ylim(5, 20)

diamonds %>%
  select(x, y, z) %>%
  summarise(
    x_mean = mean(x),
    y_mean = mean(y),
    z_mean = mean(z)
  )

ggplot(diamonds, aes(x = price)) +
  geom_histogram(binwidth = 10) +
  coord_cartesian(xlim = c(0, 2500))


diamonds %>%
  filter(carat %in% c(0.99, 1)) %>%
  group_by(carat) %>%
  count()

ggplot(diamonds, aes(x = x)) +
  geom_histogram() +
  ylim(0, 5000)

reprex::reprex({
  library(tidyverse)
  between(1:10, 3, 7)
})

# 练习 02-----
## 先创建一个含有一些缺失值的列表吧。
set.seed(1234)
a <- tibble(
  x = sample(0:1, 100, replace = TRUE) %>% factor(),
  y = rnorm(n = 100, mean = 50, sd = 50)
)
a[sample(0:100, 3), "x"] <- NA
a[sample(0:100, 5), "y"] <- NA
ggplot(a, aes(x = x)) +
  geom_bar()
ggplot(a, aes(x = y)) +
  geom_histogram()

mean(a$y)
mean(a$y, na.rm = TRUE)

nycflights13::flights |>
  mutate(
    cancelled = is.na(dep_time),
    sched_hour = sched_dep_time %/% 100,
    sched_min = sched_dep_time %% 100,
    sched_dep_time = sched_hour + (sched_min / 60)
  ) |>
  ggplot(aes(x = sched_dep_time)) +
  geom_freqpoly(aes(color = cancelled), binwidth = 1 / 4) +
  facet_wrap(~cancelled, scales = "free")


# 协同变化----
ggplot(diamonds, aes(x = price)) +
  geom_freqpoly(aes(color = cut), binwidth = 500, linewidth = 0.75)

ggplot(diamonds, aes(x = price, y = after_stat(density))) +
  geom_freqpoly(aes(color = cut), binwidth = 500, linewidth = 0.75)

ggplot(diamonds, aes(x = cut, y = price)) +
  geom_boxplot()

ggplot(mpg, aes(x = class, y = hwy)) +
  geom_boxplot()

ggplot(mpg, aes(x = fct_reorder(class, hwy, median), y = hwy)) +
  geom_boxplot()

ggplot(mpg, aes(x = fct_reorder(class, hwy, median), y = hwy)) +
  geom_boxplot() +
  coord_flip()
## 小练习

flights %>%
  mutate(cancelled = is.na(dep_time)) %>%
  ggplot(aes(x = cancelled, y = sched_dep_time)) +
  geom_boxplot(aes(fill = cancelled))

# diamonds数据price作为因变量建立多元线性回归
model <- lm(price ~ ., data = diamonds)
summary(model)

library(lvplot)
ggplot(diamonds, aes(x = cut, y = carat)) +
  geom_lv()


ggplot(diamonds, aes(x = cut, y = carat)) +
  geom_violin()

ggplot(diamonds, aes(x = carat)) +
  geom_histogram() +
  facet_wrap(~cut, scales = "free")

ggplot(diamonds, aes(x = carat)) +
  geom_freqpoly(aes(color = cut))

ggplot(diamonds, aes(x = carat)) +
  geom_density(aes(color = cut))


ggplot(diamonds, aes(x = cut, y = color)) +
  geom_count()

ggplot(diamonds, aes(x = cut, fill = color)) +
  geom_bar(position = "fill")

diamonds %>%
  count(cut, color) %>%
  ggplot(aes(x = cut, y = color)) +
  geom_tile(aes(fill = n)) +
  coord_quickmap()

# 加上数值标签
diamonds %>%
  count(cut, color) %>%
  ggplot(aes(x = cut, y = n, fill = color)) +
  geom_bar(stat = "identity", position = "dodge") +
  geom_text(aes(label = n),
    position = position_dodge(width = 0.9),
    vjust = -0.5
  )

nycflights13::flights %>%
  group_by(dest, month) %>%
  summarise(mean_dep_delay = mean(dep_delay, na.rm = TRUE)) %>%
  ggplot(aes(x = factor(month), y = dest, fill = mean_dep_delay)) +
  geom_tile()

# flights_adj转换为矩阵形式
tmp <- nycflights13::flights %>%
  group_by(dest, month) %>%
  summarise(mean_dep_delay = mean(dep_delay, na.rm = TRUE)) %>%
  mutate(month = factor(month)) %>%
  pivot_wider(names_from = dest, values_from = mean_dep_delay) %>%
  as.data.frame()
rownames(tmp) <- tmp$month
tmp <- tmp[, -1] %>% t()
# 画热图
pheatmap::pheatmap(
  tmp,
  na.color = "grey",
  cluster_rows = FALSE,
  cluster_cols = TRUE
)
library(patchwork)
smaller <- diamonds |>
  filter(carat < 3)
p1 <- ggplot(smaller, aes(x = carat, y = price)) +
  geom_point()
p2 <- ggplot(smaller, aes(x = carat, y = price)) +
  geom_point(alpha = 1 / 100)
p1 + p2


p1 <- ggplot(smaller, aes(x = carat, y = price)) +
  geom_bin2d()
p2 <- ggplot(smaller, aes(x = carat, y = price)) +
  geom_hex()
p1 + p2

ggplot(smaller, aes(x = carat, y = price)) +
  geom_boxplot(aes(group = cut_width(carat, 0.1)), varwidth = TRUE)
## 练习
p1 <- ggplot(smaller, aes(x = price)) +
  geom_freqpoly(aes(color = cut_width(carat, 0.2)))
p2 <- ggplot(smaller, aes(x = price)) +
  geom_freqpoly(aes(color = cut_number(carat, 5)))
p1 + p2

ggplot(smaller, aes(x = carat)) +
  geom_freqpoly(aes(color = cut_number(price, 5)))

ggplot(smaller, aes(x = carat, y = price, color = cut)) +
  geom_smooth()

diamonds |>
  filter(x >= 4) |>
  ggplot(aes(x = x, y = y)) +
  geom_point() +
  coord_cartesian(xlim = c(4, 11), ylim = c(4, 11))

ggplot(smaller, aes(x = carat, y = price)) +
  geom_boxplot(aes(group = cut_number(carat, 20)))

library(tidymodels)

diamonds <- diamonds |>
  mutate(
    log_price = log(price),
    log_carat = log(carat)
  )

diamonds_fit <- linear_reg() |>
  fit(log_price ~ log_carat, data = diamonds)

diamonds_aug <- augment(diamonds_fit, new_data = diamonds) |>
  mutate(.resid = exp(.resid))

ggplot(diamonds_aug, aes(x = carat, y = .resid)) +
  geom_point()

ggplot(diamonds_aug, aes(x = cut, y = .resid)) +
  geom_boxplot()

diamonds_fit
