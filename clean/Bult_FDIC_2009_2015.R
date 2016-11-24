read_csv("data/raw/Built_FDIC_2009_2015.csv") %>% 
  select(-numyear) %>%
  #arranging by not year makes it so that SQL Server import wizard can accurately classify columns by checking first 200 rows
  arrange(hrhhid) %>%
  write_csv("data/clean/Built_FDIC_2009_2015_2.csv", na = "")