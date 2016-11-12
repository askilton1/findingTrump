#for a dplyr sqlite tutorial: https://cran.r-project.org/web/packages/dplyr/vignettes/databases.html
#to download required data files:

library(tidyverse)
my_db <- src_sqlite("finding_trump.db", create = T)

#2001
read_csv("data/usa_00002.csv",
         #do not read 2015 rows
         n_max = 1192206) %>%
  #select columns where values are not 100% missing
  select_if(function(col) sum(is.na(col))/1192206 != 1) %>%
  #create new table in database
  copy_to(dest = my_db, df =  ., name = "ACS_2001", temporary = F)

#2015
read_csv("data/usa_00002.csv",
         #skip 2001 rows
         skip = 1192207,
         #can't figure out how to both skip rows and retain header
         col_names = names(read_csv("usa_00002.csv", n_max = 1))) %>%
  #select columns where values are not 100% missing
  select_if(function(col) sum(is.na(col))/1192206 != 1) %>%
  #create a new table in database
  copy_to(dest = my_db, df = ., name = "ACS_2015", temporary = F)

