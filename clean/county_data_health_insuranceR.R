#https://www.enrollamerica.org/research-maps/maps/changes-in-uninsured-rates-by-county/
library(tidyverse)

read_csv("data/raw/County_Data_2016_health_insurance.csv",
         col_types = list(county_fips = col_character())) %>% 
  setNames(gsub(pattern = " ", replacement = "_", names(.))) %>% 
  transmute(STATEFIPS = ifelse(nchar(county_fips) == 5,
                               as.numeric(substr(county_fips, start = 1, stop = 2)),
                               as.numeric(substr(county_fips, start = 1, stop = 1))),
            COUNTY = as.numeric(substr(county_fips, start = nchar(county_fips) - 2, stop = nchar(county_fips))),
            uninsured_rate_2013 = `2013_uninsured_rate` / 100,
            uninsured_rate_2016 = `2016_uninsured_rate` / 100,
            decrease_from_2013_to_2016 = decrease_from_2013_to_2016 / 100) %>% 
  rename(change = decrease_from_2013_to_2016) %>% 
  arrange(STATEFIPS, COUNTY) %>% 
  write_csv("data/clean/County_Data_2016_health_insurance.csv")