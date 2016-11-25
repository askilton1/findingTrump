library(tidyverse)

read_csv("data/raw/usa_00005.csv", col_types = cols_only(RECTYPE = col_guess(),
                                                         RELATE = col_guess(),
                                                         YEAR = col_guess(),
                                                         DATANUM = col_guess(),
                                                         SERIAL = col_guess(),
                                                         NUMPREC = col_guess(),
                                                         PERNUM = col_guess(),
                                                         REGION = col_guess(), #missing = 99
                                                         METRO = col_guess(), #missing = 0
                                                         STATEFIP = col_guess(), #99
                                                         COUNTY = col_character(), #0000
                                                         EDUC = col_character(), #001
                                                         AGE = col_guess(),
                                                         HISPAN = col_guess(), #9
                                                         HISPAND = col_guess(), #900
                                                         SEX = col_guess(),
                                                         RACE = col_guess(),
                                                         CITIZEN = col_guess(), #0
                                                         BPL = col_guess(), #999
                                                         EMPSTAT = col_guess(), #0
                                                         HHINCOME = col_guess() #9999999
                                                         )) %>%
  mutate(REGION = ifelse(REGION == 99, NA, REGION),
         METRO = ifelse(METRO == 0, NA, METRO),
         STATEFIP = ifelse(STATEFIP == 99, NA, STATEFIP),
         COUNTY = as.numeric(ifelse(COUNTY == "0000", NA, COUNTY)),
         EDUC = as.numeric(ifelse(EDUC == "001", NA, EDUC)),
         HISPAN = ifelse(HISPAN == 9, NA, HISPAN),
         HISPAND = ifelse(HISPAND == 900, NA, HISPAND),
         CITIZEN = ifelse(CITIZEN == "0", NA, CITIZEN),
         BPL = ifelse(BPL == 999, NA, BPL),
         EMPSTAT = ifelse(EMPSTAT == 0, NA, EMPSTAT),
         HHINCOME = ifelse(HHINCOME == 9999999, NA, HHINCOME)) %>%
  write_csv("data/clean/usa_00005_2.csv", na = "")