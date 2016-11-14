#place /programs in same directory along with a /data folder 
#for a dplyr sqlite tutorial: https://cran.r-project.org/web/packages/dplyr/vignettes/databases.html
#to download required data files: https://www.dropbox.com/sh/ojjasinnk17mi0m/AAAJtygVHup26jDH9Y8_bTvha?dl=0
library(tidyverse)

#if data folder does not exist or there are no files in the data folder
if(length(list.files("data")) <= 1){
  print("FILL data FOLDER WITH FILES FROM DROPBOX TO CREATE SQLite TABLES")
  dir.create("data")
  print("you will have to break and add files to disable wait period")
  print(paste("waiting", 99^99, "seconds"))
  Sys.sleep(99^99)}

#if database does not exist, create it
create <- !("finding_trump.db" %in% list.files())
my_db <- src_sqlite("finding_trump.db", create = create)
tables <- src_tbls(my_db)

#reset directory to data folder

#2001
#if the csv is available and the ACS_2001 table does not exist
if("usa_00002.csv" %in% list.files("data") & !("ACS_2001" %in% tables)){
  read_csv("data/usa_00002.csv",
           #do not read 2015 rows
           n_max = 1192206) %>%
    #select columns where values are not 100% missing
    select_if(function(col) sum(is.na(col))/1192206 != 1) %>%
    #create new table in database
    copy_to(dest = my_db, df =  ., name = "ACS_2001", temporary = F)
}

#2015
#if the csv is available and the ACS_2015 table does not exist
if("usa_00002.csv" %in% list.files("data") & !("ACS_2015" %in% tables)){
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
