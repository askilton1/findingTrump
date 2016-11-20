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

#2001_1year
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

#2015_1year
#if the csv is available and the ACS_2015 table does not exist
if("usa_00002.csv" %in% list.files("data") & !("ACS_2015" %in% tables)){
  read_csv("data/usa_00002.csv",
           #skip 2001 rows
           skip = 1192207,
           #can't figure out how to both skip rows and retain header
           col_names = names(read_csv("usa_00002.csv", n_max = 1))) %>%
    #select columns where values are not 100% missing
    select_if(function(col) sum(is.na(col))/1192206 != 1) %>%
    #create a new table in database
    copy_to(dest = my_db, df = ., name = "ACS_2015", temporary = F)
}

#2013_5year
#if the csv is available and the ACS_2013_5year table does not exist
if("usa_00005.csv" %in% list.files("data") & !("ACS_2013_5year" %in% tables)){
  read_csv("data/usa_00005.csv",
           col_types = cols_only(YEAR = col_integer(),
                                 SERIAL = col_integer(),
                                 DATANUM = col_integer(),
                                 PERNUM = col_integer(),
                                 REGION = col_integer(),
                                 STATEFIP = col_integer(),
                                 COUNTY = col_integer(),
                                 METRO = col_integer(),
                                 RACWHT = col_integer(),
                                 SEX = col_integer(),
                                 AGE = col_integer(),
                                 RELATE = col_integer(),
                                 HHINCOME = col_integer(),
                                 EDUC = col_integer(),
                                 METRO = col_integer(),
                                 POVERTY = col_integer(),
                                 LABFORCE = col_integer(),
                                 CITIZEN = col_integer(),
                                 HCOVANY = col_integer(),
                                 HCOVPRIV = col_integer(),
                                 HCOVPUB = col_integer(),
                                 HINSCAID = col_integer(),
                                 EMPSTAT = col_integer(),
                                 EMPSTATD = col_integer(),
                                 INCWELFR = col_integer(),
                                 MOVEDIN = col_integer(),
                                 MIGPLAC1 = col_integer())) %>%
    #create a new table in database
    copy_to(dest = my_db, df = ., name = "ACS_2013_5year", temporary = F)
}

#FDIC 2009-2015 AFS Census Supplement
#if the csv is available and the ACS_2015 table does not exist
if("Built_FDIC_2009_2015.csv" %in% list.files("data") & !("AFS_2009_2015" %in% tables)){
  read_csv("data/Built_FDIC_2009_2015.csv") %>%
    #create a new table in database
    copy_to(dest = my_db, df = ., name = "AFS_2009_2015", temporary = F)
}
#reset working directory in case you want to run program again
setwd(original_wd)