library(tidyverse)
#https://www.census.gov/popest/data/counties/asrh/2015/CC-EST2015-ALLDATA.html
#file in raw data has been stripped to columns as defined below:
read_csv("data/raw/CC-EST2015-ALLDATA.csv",
         col_types = cols_only(STATE = col_character(),
                               COUNTY = col_character(),
                               TOT_POP = col_integer(),
                               AGEGRP = col_integer(),
                               YEAR = col_integer(),
                               NHWA_MALE = col_integer(),
                               NHWA_FEMALE = col_integer())) %>%
  mutate(FIPS = paste0(STATE,COUNTY)) %>% 
  filter(AGEGRP >= 5,
         YEAR == 8) %>% 
  group_by(FIPS) %>% 
  summarise(TOT_POP = sum(TOT_POP),
            NHWA = sum(NHWA_MALE + NHWA_FEMALE) / sum(TOT_POP)) %>% 
  write_csv("data/clean/CC-EST2015-ALLDATA.csv")
