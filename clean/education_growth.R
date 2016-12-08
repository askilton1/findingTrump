library(tidyverse)
read_csv("data/clean/Education.csv") %>% 
  group_by(FIPS) %>% 
  summarise_at(vars(bachelorsOrMore:HSDonly), function(col) last(col) - first(col)) %>%
  write_csv("data/clean/Education_growth.csv")
