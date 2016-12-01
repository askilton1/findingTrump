#https://www.enrollamerica.org/research-maps/maps/changes-in-uninsured-rates-by-county/
library(tidyverse)

first_ten_states <- read_csv("data/raw/County_Data_2016_health_insurance.csv",
         col_types = cols_only(state_abbrev = col_character())) %>% 
  unique %>% 
  slice(1:10) %>% 
  unlist

read_csv("data/raw/County_Data_2016_health_insurance.csv",
         col_types = list(county_fips = col_character())) %>% 
  setNames(gsub(pattern = " ", replacement = "_", names(.))) %>% 
  transmute(STATEFIPS = as.numeric(substr(county_fips, start = 1, stop = 2)),
            #they messed up the state part of the county fip
            STATEFIPS = as.numeric(
              ifelse(STATEFIPS %in% state_abbrev, plyr::mapvalues(state_abbrev, first_ten_states, 1:10), STATEFIPS)
                                   ),
            COUNTY = as.numeric(substr(county_fips, start = 3, stop = 5)),
            `2013_uninsured_rate`,
            `2016_uninsured_rate`,
            decrease_from_2013_to_2016) %>% 
  rename(change = decrease_from_2013_to_2016) %>% 
  write_csv("data/clean/County_Data_2016_health_insurance.csv")
