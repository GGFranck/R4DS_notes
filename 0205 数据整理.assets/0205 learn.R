library(tidyverse)

setwd("D:/Data/知识库/R4DS学习笔记/0205 数据整理.assets")

billboard_longer<- billboard %>% 
  pivot_longer(cols = starts_with('wk'),
               names_to = 'week',
               values_to = "rank",
               values_drop_na = T) %>% 
  mutate(week = parse_number(week))

ggplot(billboard_longer,aes(x = week, y = rank,group = track))+
  geom_line(alpha = 0.5)+
  scale_y_reverse()

df <- tribble(
  ~id,  ~bp1, ~bp2,
  "A",  100,  120,
  "B",  140,  115,
  "C",  120,  125
)

df %>% pivot_longer(cols = !id,
                    names_to = 'measurement',
                    values_to = 'value')

who2 %>% pivot_longer(cols = !c(country:year),
                     names_to = c('diagnosis','gender','age'),
                     names_sep = '_',
                     values_to = 'count')

household %>% pivot_longer(cols = !family,
                           names_to = c('.value','child'),
                           names_sep = '_',
                           values_drop_na = T)

cms_patient_experience %>% 
  distinct(measure_cd,measure_title)

cms_patient_experience %>% 
  pivot_wider(
    names_from = measure_cd,
    values_from = prf_rate
  )

cms_patient_experience %>% 
  pivot_wider(id_cols = 1:2,#starts_with('org')
              names_from = measure_cd,
              values_from = prf_rate)

df <- tribble(
  ~id, ~measurement, ~value,
  "A",        "bp1",    100,
  "B",        "bp1",    140,
  "B",        "bp2",    115, 
  "A",        "bp2",    120,
  "A",        "bp3",    105
)

df %>% 
  pivot_wider(names_from = measurement,
              values_from = value)

df <- tribble(
  ~id, ~measurement, ~value,
  "A",        "bp1",    100,
  "A",        "bp1",    102,
  "A",        "bp2",    120,
  "B",        "bp1",    140, 
  "B",        "bp2",    115
)
df %>% 
  pivot_wider(names_from = measurement,
              values_from = value)

df %>% 
  group_by(id,measurement) %>% 
  count() %>% 
  filter(n > 1)
