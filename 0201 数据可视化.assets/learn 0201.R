library(tidyverse)
library(palmerpenguins)
library(ggthemes)

#散点图 拟合曲线----
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)
) +
  geom_point(mapping = aes(color = species, shape = species)) +
  geom_smooth(method = "lm")+
  labs(
    title = 'Body mass and flipper length',
    subtitle = 'Dimensions for Adelie, Chintrap, and Gentoo Penguins',
    x = 'Flipper length (mm)', y = 'Body mass (g)',
    color = 'Species', shape = 'Species'
  )+
  scale_color_colorblind()

ggplot(penguins)+
  geom_point(aes(x = bill_length_mm, y = bill_depth_mm))
ggplot(penguins)+
  geom_point(aes(x = bill_length_mm, y = bill_depth_mm),na.rm = T)

ggplot(penguins)+
  geom_jitter(aes(x = species, y = bill_depth_mm))

ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)
) +
  geom_point(mapping = aes(color = bill_depth_mm)) +
  geom_smooth()+
  theme_par()

ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g, color = island)
) +
  geom_point() +
  geom_smooth(se = FALSE)

ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)
) +
  geom_point() +
  geom_smooth()

ggplot() +
  geom_point(
    data = penguins,
    mapping = aes(x = flipper_length_mm, y = body_mass_g)
  ) +
  geom_smooth(
    data = penguins,
    mapping = aes(x = flipper_length_mm, y = body_mass_g)
  )
#分布的可视化----------
#分类变量-柱状图
ggplot(penguins, aes(x = species)) +
  geom_bar()
ggplot(penguins, aes(x = fct_infreq(species))) +
  geom_bar()
#定量变量-直方图
ggplot(penguins,aes(x = body_mass_g)) + 
  geom_histogram(binwidth = 200)

ggplot(penguins,aes(x = body_mass_g)) +
  geom_histogram(binwidth = 20)

ggplot(penguins, aes(x = body_mass_g)) +
  geom_histogram( binwidth = 2000)

ggplot(penguins, aes(x = body_mass_g)) + 
  geom_density()

#练习
ggplot(penguins,aes(y = species)) + 
  geom_bar()

ggplot(penguins, aes(x = species)) +
  geom_bar(color = "red")

ggplot(penguins, aes(x = species)) +
  geom_bar(fill = "red")

ggplot(penguins,aes(x = body_mass_g)) + 
  geom_histogram(bins = 4)

glimpse(diamonds)
ggplot(diamonds,aes(x = carat)) + 
  geom_density()
#关系的可视化--------
ggplot(penguins,aes(x = species,y = body_mass_g)) + 
  geom_boxplot()

ggplot(penguins,aes(x = body_mass_g, colour = species,fill = species)) + 
  geom_density(alpha = 0.5)

ggplot(penguins,aes(x = island, fill = species)) + 
  geom_bar()
ggplot(penguins,aes(x = island, fill = species)) + 
  geom_bar(position = 'fill')

ggplot(penguins,aes(x = flipper_length_mm, y = body_mass_g)) + 
  geom_point(aes(colour = species, shape = species)) + 
  facet_wrap(~island)

ggplot(mpg, aes(x = hwy, y = displ)) + 
  geom_point(aes(colour = cyl))
ggplot(mpg, aes(x = hwy, y = displ)) + 
  geom_point(aes(size = cyl))
ggplot(mpg, aes(x = hwy, y = displ)) + 
  geom_point(aes(colour = cyl ,size = cyl))
ggplot(mpg, aes(x = hwy, y = displ)) + 
  geom_point(aes(shape = factor(cyl)))

ggplot(mpg,aes(x = factor(cyl), y = hwy)) + 
  geom_boxplot(aes(colour = factor(cyl)))
ggplot(mpg,aes(x = factor(cyl), y = hwy)) + 
  geom_boxplot(aes(size = factor(cyl)))
ggplot(mpg,aes(x = factor(cyl), y = hwy)) + 
  geom_boxplot(aes(shape = factor(cyl)))

ggplot(penguins,aes(x = bill_length_mm, y = bill_depth_mm)) + 
  geom_point(aes(colour = species))
ggplot(penguins,aes(x = bill_length_mm, y = bill_depth_mm)) + 
  geom_point(aes(colour = species))+
  facet_wrap(~species)

ggplot(penguins, aes(x = island, fill = species)) +
  geom_bar(position = "fill")
ggplot(penguins, aes(x = species, fill = island)) +
  geom_bar(position = "fill")

#保存-----
p1<-ggplot(mpg, aes(x = class)) +
  geom_bar()
ggplot(mpg, aes(x = cty, y = hwy)) +
  geom_point()
ggsave(plot = p1,"mpg-plot.pdf",path = 'D:/Data/大五/文献复现/R4DS学习笔记/0201 数据可视化.assets/')

