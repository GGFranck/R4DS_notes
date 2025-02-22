library(tidyverse)
library(ggplot2)
library(patchwork)
library(ggridges)
library(cowplot)

#map aes---------
p1 <- ggplot(mpg,aes(x = displ, y = hwy, color = class))+
  geom_point()
p2 <- ggplot(mpg,aes(x = displ, y = hwy, shape = class))+
  geom_point()
p1+p2
ggsave('01 点的颜色和形状.png',width = 14, height = 7)

p1 <- ggplot(mpg,aes(x = displ, y = hwy, size = class))+
  geom_point()
p2 <- ggplot(mpg,aes(x = displ, y = hwy, alpha = class))+
  geom_point()
p1+p2
ggsave('02 点的大小和不透明度.png',width = 14, height = 7)

ggplot(mpg,aes(x = displ, y = hwy))+
  geom_point(color = 'blue')
ggsave('03 aes之外映射点的颜色.png')

#exercise 01----
ggplot(mpg,aes(x = displ, y = hwy))+
  geom_point(shape = 24,fill = 'pink',size = 4)
ggsave('04 有fill的点.png')

ggplot(mpg) + 
  geom_point(aes(x = displ, y = hwy),color = 'blue')
ggsave('05 点的颜色映射的写在哪里.png')

ggplot(mpg,aes(x = displ, y = hwy)) + 
  geom_point()

#几何对象----------
p1 <- ggplot(mpg,aes(x = displ, y = hwy, shape = drv))+
  geom_smooth()
p2 <- ggplot(mpg,aes(x = displ, y = hwy, linetype = drv))+
  geom_smooth()
p1+p2
ggsave('06 linetype才能调整线的类型.png')

ggplot(mpg,aes(x = displ, y = hwy, colour = drv))+
  geom_point()+
  geom_smooth(aes(linetype = drv))

ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_smooth(aes(group = drv,colour = drv))

ggplot(mpg, aes(x = displ, y = hwy)) + 
  geom_point(aes(color = class)) + 
  geom_smooth()

ggplot(mpg, aes(x = displ, y = hwy)) + 
  geom_point() + 
  geom_point(
    data = mpg |> filter(class == "2seater"), 
    color = "red"
  ) +
  geom_point(
    data = mpg |> filter(class == "2seater"), 
    shape = "circle open", size = 3, color = "red"
  )

# Left
ggplot(mpg, aes(x = hwy)) +
  geom_histogram(binwidth = 2)

# Middle
ggplot(mpg, aes(x = hwy)) +
  geom_density()

# Right
ggplot(mpg, aes(x = hwy)) +
  geom_boxplot()

ggplot(mpg, aes(x = hwy, y = drv, fill = drv, colour = drv))+
  geom_density_ridges(alpha = 0.5, show.legend = F)

ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_smooth(aes(color = drv))

#excercise 02-----

p1 <- ggplot(mpg,aes(x = displ, y = hwy))+
  geom_point()+
  geom_smooth(se = F)
p2 <- ggplot(mpg,aes(x = displ, y = hwy))+
  geom_point()+
  geom_smooth(se = F,aes(group = drv))
p3 <- ggplot(mpg,aes(x = displ, y = hwy, colour = drv))+
  geom_point()+
  geom_smooth(se = F)
p4 <- ggplot(mpg,aes(x = displ, y = hwy))+
  geom_point(aes(colour = drv))+
  geom_smooth(se = F)
p5 <- ggplot(mpg,aes(x = displ, y = hwy))+
  geom_point(aes(colour = drv))+
  geom_smooth(se = F,aes(linetype = drv))
p6 <- ggplot(mpg,aes(x = displ, y = hwy,fill = drv))+
  geom_point(shape = 21,stroke = 2,color = 'white')

#分面----
ggplot(mpg,aes(x = displ, y = hwy))+
  geom_point()+
  facet_wrap(~cyl)

ggplot(mpg,aes(x = displ, y = hwy))+
  geom_point()+
  facet_wrap(drv~cyl,scales = 'free')

#exercise03----
n <- 100;set.seed(1234)
a <- tibble(
  x = sample(1:n,n,replace = T),
  y = runif(n),
  z = rnorm(n)
)
ggplot(a,aes(x = y,y = z))+
  geom_point()+
  facet_wrap(~x)

ggplot(mpg) + 
  geom_point(aes(x = drv, y = cyl))

ggplot(mpg) + 
  geom_point(aes(x = displ, y = hwy)) +
  facet_grid(drv ~ .)
ggplot(mpg) + 
  geom_point(aes(x = displ, y = hwy)) +
  facet_grid(. ~ cyl)
ggplot(mpg) + 
  geom_point(aes(x = displ, y = hwy)) +
  facet_grid(drv ~ cyl)

ggplot(mpg) + 
  geom_point(aes(x = displ, y = hwy)) + 
  facet_wrap(~cyl, nrow = 1)
ggplot(mpg, aes(x = displ)) + 
  geom_histogram() + 
  facet_grid(drv ~ .)

ggplot(mpg) + 
  geom_point(aes(x = displ, y = hwy)) +
  facet_grid(drv ~ .)
ggplot(mpg) + 
  geom_point(aes(x = displ, y = hwy)) +
  facet_wrap( ~ drv, ncol = 1)

#统计转换----
ggplot(diamonds,aes(x = cut))+
  geom_bar()

diamonds |>
  count(cut) |>
  ggplot(aes(x = cut, y = n)) +
  geom_bar(stat = "identity")

diamonds |>
  count(cut) |>
  ggplot(aes(x = cut, y = n)) +
  geom_col()

ggplot(diamonds, aes(x = cut, y = after_stat(prop), group = 1))+
  geom_bar()

ggplot(diamonds)+
  stat_summary(
    aes(x = cut, y = depth),
    fun.min = min,
    fun.max = max,
    fun = median
  )
#exercise 03----
diamonds %>% 
  group_by(cut) %>% 
  summarise(median_depth = median(depth),
            min_depth = min(depth),
            max_depth = max(depth)) %>% 
  ggplot()+
  geom_errorbar(aes(x = cut,ymin = min_depth, ymax = max_depth),width = 0)+
  geom_point(aes(x = cut,y = median_depth))

diamonds %>% 
  count(cut) %>% 
  ggplot(aes(x = cut, y= n))+
    geom_col()

ggplot(diamonds,aes(x = cut,fill = clarity))+
  stat_count()
#位置调整---------
# Left
ggplot(mpg, aes(x = drv, color = drv)) + 
  geom_bar()

# Right
ggplot(mpg, aes(x = drv, fill = drv)) + 
  geom_bar()

# Left
ggplot(mpg, aes(x = drv, fill = class)) + 
  geom_bar(alpha = 1/5, position = "identity")

# Right
ggplot(mpg, aes(x = drv, color = class)) + 
  geom_bar(fill = NA, position = "identity")

p1 <- ggplot(mpg, aes(x = drv, fill = class)) + 
  geom_bar(position = "fill")
p2 <- ggplot(mpg, aes(x = drv, fill = class)) + 
  geom_bar(position = "dodge")
p1+p2
ggsave('./08 百分比和簇状柱形图.png',width = 8,height = 4)

ggplot(mpg, aes(x = displ, y = hwy)) + 
  geom_point(position = "jitter")

ggplot(mpg, aes(x = displ, y = hwy))+
  geom_jitter()
#练习04----
ggplot(mpg, aes(x = cty, y = hwy)) + 
  geom_point(position = 'jitter')
mpg %>% count(cty,hwy)

ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point()
ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(position = "identity")

a <- tibble(
  x = rep(1:4,20),
  y = runif(4*20,min = 0, max =10) %>% round()
)
ggplot(a,aes(x=x,y=y))+
  geom_jitter(width = 0.2,height = 0)

ggplot(mpg, aes(cty, hwy)) +
  geom_point()
ggplot(mpg, aes(cty, hwy)) +
  geom_count()
ggsave('./09 geom_count的效果.png')

ggplot(mpg,aes(x = drv, y = cty, fill = factor(year)))+
  geom_boxplot(position = 'dodge2')
ggsave('./10 boxplot的默认参数.png')

#坐标轴----
nz <- map_data("nz")

ggplot(nz, aes(x = long, y = lat, group = group)) +
  geom_polygon(fill = "white", color = "black")

ggplot(nz, aes(x = long, y = lat, group = group)) +
  geom_polygon(fill = "white", color = "black") +
  coord_quickmap()

bar <- ggplot(data = diamonds) + 
  geom_bar(
    mapping = aes(x = clarity, fill = clarity), 
    show.legend = FALSE,
    width = 1
  ) + 
  theme(aspect.ratio = 1);bar

bar + coord_flip()
bar + coord_polar()

plot_grid(bar,bar + coord_flip(),bar + coord_polar())
#exercise 05-----
ggplot(mpg,aes(x = fl,fill = drv))+
  geom_bar(position = 'stack',width = 1)+
  coord_polar()

ggplot(nz, aes(x = long, y = lat, group = group)) +
  geom_polygon(fill = "white", color = "black") +
  coord_map()
ggplot(nz, aes(x = long, y = lat, group = group)) +
  geom_polygon(fill = "white", color = "black") +
  coord_quickmap()
ggplot(data = mpg, mapping = aes(x = cty, y = hwy)) +
  geom_point() + 
  geom_abline() +
  coord_fixed()

a <- tibble(
  x = 1:10*10,
  y = 1:10
)
ggplot(a,aes(x,y))+
  geom_point()+
  coord_fixed()
