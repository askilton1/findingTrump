my_db <- src_sqlite("finding_trump.db", create = F)
my_db

tbl(my_db, sql("select poverty from ACS_2015 limit 5")) %>%
  collect %>%
  names

#calculate number of counties using SQLite query
tbl(my_db, sql("select count(distinct COUNTYFIPS) from ACS_2015"))

#calculate number of counties using R. this is faster
tbl(my_db, sql("select distinct COUNTYFIPS from ACS_2015")) %>%
  collect