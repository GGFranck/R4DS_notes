library(tidyverse)
library(ggplot2)
library(ggrepel)
library(patchwork)
library(scales)
library(ggthemes)
library(ggprism)
# 图例-----
ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(aes(color = class)) +
  geom_smooth(se = FALSE) +
  labs(
    x = "Engine displacement (L)",
    y = "Highway fuel economy (mpg)",
    color = "Car type",
    title = "Fuel efficiency generally decreases with engine size",
    subtitle = "Two seaters (sports cars) are an exception because of their light weight",
    caption = "Data from fueleconomy.gov"
  )

df <- tibble(
  x = 1:10,
  y = cumsum(x^2)
)
reprex::reprex({
  cumsum(1:10)
})
ggplot(df, aes(x, y)) +
  geom_point() +
  labs(
    x = quote(x[i]),
    y = quote(sum(x[i]^2, i == 1, n))
  )
## 练习
ggplot(mpg, aes(x = cty, y = hwy)) +
  geom_point(aes(color = drv, shape = drv)) +
  labs(
    x = "City MPG",
    y = "Highway MPG",
    color = "Type of drive train",
    shape = "Type of drive train",
    title = "Relationship between city and highway mpg",
    subtitle = "Each point represents a car",
    caption = "Source: fueleconomy.gov"
  )
# 注记--------
label_info <- mpg |>
  group_by(drv) |>
  arrange(desc(displ)) |>
  slice_head(n = 1) |>
  mutate(
    drive_type = case_when(
      drv == "f" ~ "front-wheel drive",
      drv == "r" ~ "rear-wheel drive",
      drv == "4" ~ "4-wheel drive"
    )
  ) |>
  select(displ, hwy, drv, drive_type)

ggplot(mpg, aes(x = displ, y = hwy, color = drv)) +
  geom_point(alpha = 0.3) +
  geom_smooth(se = FALSE) +
  geom_text(
    data = label_info,
    aes(x = displ, y = hwy, label = drive_type),
    fontface = "bold", size = 5, hjust = "right", vjust = "bottom"
  ) +
  theme(legend.position = "none")

ggplot(mpg, aes(x = displ, y = hwy, color = drv)) +
  geom_point(alpha = 0.3) +
  geom_smooth(se = FALSE) +
  geom_label_repel(
    data = label_info,
    aes(x = displ, y = hwy, label = drive_type),
    fontface = "bold", size = 5, nudge_y = 2
  ) +
  theme(legend.position = "none")

potential_outliers <- mpg |>
  filter(hwy > 40 | (hwy > 20 & displ > 5))

ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point() +
  geom_label_repel(
    data = potential_outliers,
    aes(label = model)
  ) +
  geom_point(data = potential_outliers, color = "red") +
  geom_point(
    data = potential_outliers,
    color = "red", size = 3, shape = "circle open"
  )

set.seed(1234)
a <- tibble(
  x = rnorm(800, mean = 0, sd = 5),
  y = rnorm(800, mean = 0, sd = 5)
)
a <- a %>%
  mutate(
    color = if_else(abs(x) < 5 & abs(y) < 5, "blue", "grey")
  )
ggplot(a, aes(x = x, y = y)) +
  geom_hline(yintercept = 0, color = "pink", linewidth = 2) +
  geom_vline(xintercept = 0, color = "pink", linewidth = 2) +
  geom_point(aes(color = color)) +
  geom_rect(
    xmin = -5, xmax = 5, ymin = -5,
    ymax = 5, fill = NA, color = "blue"
  ) +
  geom_segment(
    x = -10, y = -10, xend = -5, yend = -5,
    color = "#3ab6eb", arrow = arrow(length = unit(0.3, "cm"))
  ) +
  scale_color_manual(values = c("blue", "grey"))

trend_text <- "Larger engine sizes tend to have lower fuel economy." |>
  str_wrap(width = 30)
trend_text
#> [1] "Larger engine sizes tend to\nhave lower fuel economy."

ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point() +
  annotate(
    geom = "label", x = 3.5, y = 38,
    label = trend_text,
    hjust = "left", color = "red"
  ) +
  annotate(
    geom = "segment",
    x = 3, y = 35, xend = 5, yend = 25, color = "red",
    arrow = arrow(type = "closed")
  )

## 练习
a <- tibble(
  x = rnorm(800, mean = 0, sd = 5),
  y = rnorm(800, mean = 0, sd = 5)
)

# Use geom_text() with infinite positions to place text at the four corners of the plot.
ggplot(a, aes(x = x, y = y)) +
  geom_point() +
  geom_text(
    label = "Top-left", x = -Inf, y = Inf, hjust = -0.1, vjust = 1.1
  ) +
  geom_text(
    label = "Top-right", x = Inf, y = Inf, hjust = 1.1, vjust = 1.1
  ) +
  geom_text(
    label = "Bottom-left", x = -Inf, y = -Inf, hjust = -0.1, vjust = -0.1
  ) +
  geom_text(
    label = "Bottom-right", x = Inf, y = -Inf, hjust = 1.1, vjust = -0.1
  )

ggplot(a, aes(x = x, y = y)) +
  geom_point() +
  annotate(
    geom = "point",
    x = 0, y = 0,
    color = "red", size = 20, alpha = 0.8
  )

a <- a %>%
  mutate(facet = sample(c("a", "b", "c"), 800, replace = TRUE))
p <- ggplot(a, aes(x = x, y = y)) +
  geom_point(aes(color = facet)) +
  facet_wrap(~facet, ncol = 3)
p + geom_text(
  label = "Top-left", x = -Inf, y = Inf, hjust = -0.1, vjust = 1.1
)
# put a different label in each facet
b <- a %>%
  group_by(facet) %>%
  slice_head(n = 1) %>%
  mutate(x = Inf, y = Inf)
p + geom_text(
  data = b,
  aes(label = facet, color = facet),
  hjust = 1.1, vjust = 1.1,
  size = 5, fontface = "bold"
)

ggplot(a, aes(x = x, y = y)) +
  geom_point(aes(color = facet)) +
  geom_segment(
    x = -Inf, y = -Inf, xend = Inf, yend = Inf,
    arrow = arrow(
      length = unit(0.3, "cm"),
      type = "closed",
      angle = 45,
      ends = "both"
    )
  )

# 坐标轴------
p1 <- ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(aes(color = class))
ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(aes(color = class)) +
  scale_x_continuous() +
  scale_y_continuous() +
  scale_color_discrete()

p2 <- ggplot(mpg, aes(x = displ, y = hwy, color = drv)) +
  geom_point() +
  scale_y_continuous(breaks = seq(15, 40, by = 5))
p1 + p2

ggplot(mpg, aes(x = displ, y = hwy, color = drv)) +
  geom_point() +
  scale_y_continuous(breaks = c(18, 30, 36), labels = c("xx", "hh", "ss"))

ggplot(mpg, aes(x = displ, y = hwy, color = drv)) +
  geom_point() +
  scale_x_continuous(labels = NULL) +
  scale_y_continuous(labels = NULL) +
  scale_color_discrete(labels = c("4" = "4-wheel", "f" = "front", "r" = "rear"))

# Left
p1 <- ggplot(diamonds, aes(x = price, y = cut)) +
  geom_boxplot(alpha = 0.05) +
  scale_x_continuous(labels = label_dollar())
# Right
p2 <- ggplot(diamonds, aes(x = price, y = cut)) +
  geom_boxplot(alpha = 0.05) +
  scale_x_continuous(
    labels = label_dollar(scale = 1 / 1000, suffix = "K"),
    breaks = seq(1000, 19000, by = 6000)
  )
p1 + p2
ggplot(diamonds, aes(x = cut, fill = clarity)) +
  geom_bar(position = "fill") +
  scale_y_continuous(name = "Percentage", labels = label_percent())

presidential |>
  mutate(id = 33 + row_number()) |>
  ggplot(aes(x = start, y = id)) +
  geom_point() +
  geom_segment(aes(xend = end, yend = id)) +
  scale_x_date(name = NULL, breaks = presidential$start, date_labels = "'%y")

ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(aes(color = class)) +
  theme(legend.position = "top") +
  guides(color = guide_legend(nrow = 3))

ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(aes(color = class)) +
  geom_smooth(se = FALSE) +
  theme(legend.position = "bottom") +
  guides(color = guide_legend(nrow = 2, override.aes = list(size = 4)))

ggplot(diamonds, aes(x = carat, y = price)) +
  geom_bin2d() +
  scale_x_log10() +
  scale_y_log10()

ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(aes(color = drv))

ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(aes(color = drv)) +
  scale_color_brewer(palette = "BrBG", direction = -1)

presidential |>
  mutate(id = 33 + row_number()) |>
  ggplot(aes(x = start, y = id, color = party)) +
  geom_point() +
  geom_segment(aes(xend = end, yend = id)) +
  scale_color_manual(values = c(Republican = "#E81B23", Democratic = "#00AEF3"))

df <- tibble(
  x = rnorm(10000),
  y = rnorm(10000)
)

p1 <- ggplot(df, aes(x, y)) +
  geom_hex() +
  coord_fixed() +
  labs(title = "gradient", x = NULL, y = NULL) +
  scale_fill_gradient(low = "blue", high = "red")
p2 <- ggplot(df, aes(x, y)) +
  geom_hex() +
  coord_fixed() +
  labs(title = "gradient2", x = NULL, y = NULL) +
  scale_fill_gradient2(low = "blue", mid = "white", high = "red", midpoint = 50)
p1 + p2

ggplot(df, aes(x, y)) +
  geom_hex() +
  coord_fixed() +
  labs(title = "gradient3", x = NULL, y = NULL) +
  scale_fill_gradientn(colours = c("blue", "white", "red"))

ggplot(df, aes(x, y)) +
  geom_hex() +
  coord_fixed() +
  labs(title = "gradient3", x = NULL, y = NULL) +
  scale_fill_binned(low = "blue", high = "red", breaks = seq(0, 100, by = 10))

# 缩放----
# Left
ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(aes(color = drv)) +
  geom_smooth()

# Right
mpg |>
  filter(displ >= 5 & displ <= 6 & hwy >= 10 & hwy <= 25) |>
  ggplot(aes(x = displ, y = hwy)) +
  geom_point(aes(color = drv)) +
  geom_smooth()
# Left
ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(aes(color = drv)) +
  geom_smooth() +
  scale_x_continuous(limits = c(5, 6)) +
  scale_y_continuous(limits = c(10, 25))

# Right
ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(aes(color = drv)) +
  geom_smooth() +
  coord_cartesian(xlim = c(5, 6), ylim = c(10, 25))

suv <- mpg |> filter(class == "suv")
compact <- mpg |> filter(class == "compact")

# Left
ggplot(suv, aes(x = displ, y = hwy, color = drv)) +
  geom_point()

# Right
ggplot(compact, aes(x = displ, y = hwy, color = drv)) +
  geom_point()

x_scale <- scale_x_continuous(limits = range(mpg$displ))
y_scale <- scale_y_continuous(limits = range(mpg$hwy))
col_scale <- scale_color_discrete(limits = unique(mpg$drv))

# Left
ggplot(suv, aes(x = displ, y = hwy, color = drv)) +
  geom_point() +
  x_scale +
  y_scale +
  col_scale

# Right
ggplot(compact, aes(x = displ, y = hwy, color = drv)) +
  geom_point() +
  x_scale +
  y_scale +
  col_scale

## 练习
df <- tibble(
  x = rnorm(10000),
  y = rnorm(10000)
)

ggplot(df, aes(x, y)) +
  geom_hex() +
  coord_fixed() +
  scale_fill_gradient(name = "wow", low = "blue", high = "red")


presidential |>
  mutate(id = 33 + row_number()) |>
  ggplot(aes(x = start, y = id, color = party)) +
  geom_point() +
  geom_segment(aes(xend = end, yend = id)) +
  scale_x_date(date_breaks = "4 years", date_labels = "%Y") +
  coord_cartesian(xlim = c(as.Date("1950/1/1"), as.Date("2020/1/1"))) +
  scale_color_manual(values = c(Republican = "#E81B23", Democratic = "#00AEF3")) +
  scale_y_continuous(breaks = 1:length(presidential$name) + 33, labels = presidential$name) +
  labs(
    x = "year",
    y = "president",
    color = "Party",
    title = "Presidential Periods",
    subtitle = "1950-2020",
    caption = "Source: https://github.com/rfordatascience/tidytuesday/tree/master/data/2020/2020-01-21"
  )

ggplot(diamonds, aes(x = carat, y = price)) +
  geom_point(aes(color = cut), alpha = 1 / 20) +
  guides(color = guide_legend(override.aes = list(alpha = 1)))

# 主题----
ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(aes(color = class)) +
  geom_smooth(se = FALSE) +
  theme_void()

ggplot(mpg, aes(x = displ, y = hwy, color = drv)) +
  geom_point() +
  labs(
    title = "Larger engine sizes tend to have lower fuel economy",
    caption = "Source: https://fueleconomy.gov."
  ) +
  theme(
    legend.position = c(0.6, 0.7),
    legend.direction = "horizontal",
    legend.box.background = element_rect(color = "black"),
    plot.title = element_text(face = "bold"),
    plot.title.position = "plot",
    plot.caption.position = "plot",
    plot.caption = element_text(hjust = 0)
  )
# Make the axis labels of your plot blue and bolded.
ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(aes(color = class)) +
  geom_smooth(se = FALSE) +
  theme_prism() +
  theme(axis.text.x = element_text(color = "blue", face = "bold"))


# 布局----------
p1 <- ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point() +
  labs(title = "Plot 1")
p2 <- ggplot(mpg, aes(x = drv, y = hwy)) +
  geom_boxplot() +
  labs(title = "Plot 2")
p1 + p2

p3 <- ggplot(mpg, aes(x = cty, y = hwy)) +
  geom_point() +
  labs(title = "Plot 3")
(p1 | p3) / p2
####
p1 <- ggplot(mpg, aes(x = drv, y = cty, color = drv)) +
  geom_boxplot(show.legend = FALSE) +
  labs(title = "Plot 1")

p2 <- ggplot(mpg, aes(x = drv, y = hwy, color = drv)) +
  geom_boxplot(show.legend = FALSE) +
  labs(title = "Plot 2")

p3 <- ggplot(mpg, aes(x = cty, color = drv, fill = drv)) +
  geom_density(alpha = 0.5) +
  labs(title = "Plot 3")

p4 <- ggplot(mpg, aes(x = hwy, color = drv, fill = drv)) +
  geom_density(alpha = 0.5) +
  labs(title = "Plot 4")

p5 <- ggplot(mpg, aes(x = cty, y = hwy, color = drv)) +
  geom_point(show.legend = FALSE) +
  facet_wrap(~drv) +
  labs(title = "Plot 5")

(guide_area() / (p1 + p2) / (p3 + p4) / p5) +
  plot_annotation(
    title = "City and highway mileage for cars with different drive trains",
    caption = "Source: https://fueleconomy.gov."
  ) +
  plot_layout(
    guides = "collect",
    heights = c(1, 3, 2, 4)
  ) &
  theme(legend.position = "top")
## 练习
p1 <- ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point() +
  labs(title = "Plot 1")
p2 <- ggplot(mpg, aes(x = drv, y = hwy)) +
  geom_boxplot() +
  labs(title = "Plot 2")
p3 <- ggplot(mpg, aes(x = cty, y = hwy)) +
  geom_point() +
  labs(title = "Plot 3")

p1 / p2 | p3
p1 / (p2 + p3) + plot_annotation(
  tag_levels = c("A"), tag_prefix = "Fig. ",
  tag_sep = ".", tag_suffix = ":"
)
