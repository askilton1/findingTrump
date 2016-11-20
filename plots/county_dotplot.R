library(tidyverse)
source("survey_label_mapper.R")
my_db <- src_sqlite("finding_trump.db", create = F)

#on county level data
# STRUCTURE SQL QUERY USING DPLYR
# Capped income at 250,000
tbl(my_db, sql("select a.YEAR, a.SERIAL, a.STATEFIP, a.COUNTY, a.REGION, a.METRO, a.RACWHT, a.AGE, a.HHINCOME, b.HHEDUC 
               from ACS_2013_5year a
               left outer join (
               select YEAR, SERIAL, max(EDUC) as HHEDUC
               from ACS_2013_5year 
               group by SERIAL) b
               on (a.SERIAL = b.SERIAL AND a.YEAR = b.YEAR)
               where HHINCOME < 2000000 and EDUC != 0")) %>%
  #EXTRACT DATA FROM DATABASE USING collect()
  collect(., n = Inf) %>%
  survey_label_mapper() -> temp

temp %>%
  filter(COUNTY != 0) %>%
  group_by(STATEFIP, COUNTY) %>%
  mutate(college = ifelse(HHEDUC == "Bachelors Degree" | HHEDUC == "Postgraduate study", 1, 0)) %>%
  summarise(n = n(),
            percent_white = mean(RACWHT),
            percent_college = mean(college),
            mean_hhincome = mean(HHINCOME),
            majority_minority = as.factor(ifelse(mean(RACWHT) >= .5, 0, 1)),
            metropolitan = as.factor(ifelse(mean(METRO) > 0.5, 1, 0))
            ) %>%
ggplot(aes(x = mean_hhincome, y = percent_college, size = n, color = metropolitan, alpha = metropolitan)) +
  geom_point() + 
  theme_minimal()

