library(tidyverse)
#https://www.census.gov/popest/data/counties/asrh/2015/CC-EST2015-ALLDATA.html
read_csv("data/raw/CC-EST2015-ALLDATA.csv",
         col_types = cols_only(STATE = col_integer(),
                               COUNTY = col_integer(),
                               TOT_POP = col_integer(),
                               AGEGRP = col_integer(),
                               YEAR = col_integer(),
                               NHWA_MALE = col_integer(),
                               NHWA_FEMALE = col_integer())) %>% 
  filter(AGEGRP >= 5,
         YEAR == 8) %>% 
  rename(STATEFIPS = STATE) %>%
  group_by(STATEFIPS, COUNTY) %>% 
  summarise(NHWA = sum(NHWA_MALE + NHWA_FEMALE) / sum(TOT_POP)) %>% 
  write_csv("data/clean/CC-EST2015-ALLDATA.csv")
