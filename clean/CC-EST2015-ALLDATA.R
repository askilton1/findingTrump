library(tidyverse)

### RANDOM FOREST ----
read_csv("data/raw/CC-EST2015-ALLDATA.csv",
         col_types = list(STATE = col_integer(),
                          COUNTY = col_integer())) %>% 
  filter(AGEGRP >= 5,
         YEAR == 8) %>% 
  rename(STATEFIPS = STATE) %>% 
  group_by(STATEFIPS, COUNTY, AGEGRP) %>% 
  summarise_at(vars(TOT_POP:HNAC_FEMALE), sum) %>% 
  ungroup %>% 
  mutate_at(vars(TOT_MALE:HNAC_FEMALE), funs(. / TOT_POP)) %>% 
  write_csv("data/clean/CC-EST2015-ALLDATA.csv")