#place /programs in same directory along with a /data folder 
#for a dplyr sqlite tutorial: https://cran.r-project.org/web/packages/dplyr/vignettes/databases.html
#to download required data files: https://www.dropbox.com/sh/ojjasinnk17mi0m/AAAJtygVHup26jDH9Y8_bTvha?dl=0
library(tidyverse); library(RSQLite)

original_wd <- getwd()
#reset directory to folder containing folder containing .Rproj file
new_wd <- gsub("programs", "", getwd())
setwd(new_wd)

#if database does not exist, create it
create <- !("finding_trump.db" %in% list.files())
my_db <- src_sqlite("finding_trump.db", create = create)
tables <- src_tbls(my_db)

#reset directory to data folder
setwd(paste0(new_wd, "data"))

#2001
#if the csv is available and the ACS_2001 table does not exist
if("usa_00002.csv" %in% list.files() & !("ACS_2001" %in% tables)){
  read_csv("usa_00002.csv",
           #do not read 2015 rows
           n_max = 1192206) %>%
    #select columns where values are not 100% missing
    select_if(function(col) sum(is.na(col))/1192206 != 1) %>%
    #create new table in database
    copy_to(dest = my_db, df =  ., name = "ACS_2001", temporary = F)
}

#2015
#if the csv is available and the ACS_2015 table does not exist
if("usa_00002.csv" %in% list.files() & !("ACS_2015" %in% tables)){
read_csv("usa_00002.csv",
         #skip 2001 rows
         skip = 1192207,
         #can't figure out how to both skip rows and retain header
         col_names = names(read_csv("usa_00002.csv", n_max = 1))) %>%
  #select columns where values are not 100% missing
  select_if(function(col) sum(is.na(col))/1192206 != 1) %>%
  #create a new table in database
  copy_to(dest = my_db, df = ., name = "ACS_2015", temporary = F)
}

#reset working directory in case you want to run program again
setwd(original_wd)
