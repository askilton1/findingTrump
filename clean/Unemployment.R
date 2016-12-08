library(tidyverse)
read_csv("data/raw/Unemployment.csv", skip = 6, 
         col_types = cols_only(FIPS_Code = col_character(),
                               Unemployment_rate_2015 = col_double(),
                               Median_Household_Income_2014 = col_number())) %>% 
  transmute(FIPS = FIPS_Code,
            Unemployment_rate_2015 = Unemployment_rate_2015 / 100,
            Median_Household_Income_2014) %>%
  filter(substr(FIPS, start = 5, stop = 5) != 0) %>% 
  write_csv("data/clean/Unemployment.csv")