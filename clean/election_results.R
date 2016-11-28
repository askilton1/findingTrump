library(tidyverse)

substrRight <- function(x, n){
  substr(x, nchar(x)-n+1, nchar(x))
}

read_csv("data/raw/Pres_Election_Data_2016i.csv", 
         na = "-", 
         col_types = cols_only(X1 = col_character(),
                               FIPS = col_character(),
                               ST = col_integer(),
                               X2 = col_character(),
                               Clinton = col_character(),
                               Trump = col_character(),
                               LSAD_TRANS = col_character())) %>% 
  filter(LSAD_TRANS != "State") %>% 
  select(-LSAD_TRANS) %>% 
  slice(-1) %>% 
  rename(county_name = X1, 
         STATEABB = X2,
         COUNTY = FIPS,
         STATEFIPS = ST) %>% 
  mutate_at(3:4, funs(as.numeric(gsub("%", "", .))/100)) %>% 
  na.omit %>% 
  mutate(COUNTY = as.numeric(substrRight(COUNTY, 3))) %>% 
  write_csv("data/clean/Pres_Election_DatA_2016i.csv", na = "")