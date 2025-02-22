#练习----
library(tidyverse)

ggplot(data = mpg) + 
  geom_point(aes(x = displ, y = hwy))
  #geom_smooth(method = "lm")

ggplot(data = mpg,aes(x = displ,y = hwy))+
  geom_point()+
  geom_smooth(method = 'lm', se = F)