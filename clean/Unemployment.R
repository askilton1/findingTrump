library(tidyverse)

read_csv("data/raw/Unemployment.csv", skip = 6, 
         col_types = cols_only(FIPS_Code = col_character(),
                               Unemployment_rate_2015 = col_double(),
                               Civilian_labor_force_2015 = col_number())) %>% 
  mutate(COUNTY = as.numeric(substr(FIPS_Code, 3, 5)),
         STATEFIPS = as.numeric(substr(FIPS_Code, 1, 2))) %>% 
  select(-FIPS_Code) %>% 
  write_csv("data/clean/Unemployment.csv")