library(tidyverse)
read_csv("data/clean/Education.csv") %>% 
  group_by(STATEFIPS, COUNTY) %>% 
  summarise_at(vars(bachelorsOrMore:HSDonly), function(col) last(col) - first(col)) %>% 
  inner_join(read_csv("data/clean/Pres_Election_Data_2016i.csv")) %>% 
  select(STATEFIPS, COUNTY, vote_difference, victor, bachelorsOrMore:HSDonly) %>% 
  write_csv("data/clean/Education_growth.csv")
