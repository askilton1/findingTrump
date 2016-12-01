#https://wonder.cdc.gov/cmf-ICD10.html

library(tidyverse)
read_tsv("data/raw/Compressed Mortality, 1999-2014.txt",
         col_types = list(`County Code` = col_character())) %>%
  setNames(gsub(pattern = " ", replacement = "", names(.))) %>% 
  arrange(CountyCode, desc(Year)) %>% 
  group_by(CountyCode) %>% 
  slice(1) %>% 
  transmute(STATEFIPS = as.numeric(substr(CountyCode, start = 1, stop = 2)),
            COUNTY = as.numeric(substr(CountyCode, start = 3, stop = 5)),
            maleSuicidesPer100k = as.numeric(substr(CrudeRate, start = 1, stop = 4)) / 100) %>% 
  write_tsv("data/clean/Compressed Mortality, 1999-2014.txt")