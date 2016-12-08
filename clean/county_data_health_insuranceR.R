#https://www.enrollamerica.org/research-maps/maps/changes-in-uninsured-rates-by-county/
library(tidyverse)
read_csv("data/raw/County_Data_2016_health_insurance.csv",
         col_types = list(county_fips = col_character())) %>% 
  setNames(gsub(pattern = " ", replacement = "_", names(.))) %>% 
  transmute(FIPS = ifelse(nchar(county_fips) == 5,
                          county_fips,
                          paste0("0", county_fips)),
            uninsured_rate_2013 = `2013_uninsured_rate` / 100,
            uninsured_rate_2016 = `2016_uninsured_rate` / 100,
            decrease_from_2013_to_2016 = decrease_from_2013_to_2016 / 100) %>% 
  rename(change = decrease_from_2013_to_2016) %>% 
  arrange(FIPS) %>% 
  write_csv("data/clean/County_Data_2016_health_insurance.csv")
