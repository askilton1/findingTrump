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
  mutate(college = ifelse(HHEDUC == "Bachelors Degree" | HHEDUC == "Postgraduate study", 1, 0),
         METRO = ifelse(METRO == "In metro area", 1, 0)) %>%
  summarise(n = n() / 1000,
            percent_white = mean(RACWHT),
            percent_college = mean(college),
            income_gap = as.numeric(summary(HHINCOME)[5] - summary(HHINCOME)[2]) / 1000,
            #metropolitan = as.factor(ifelse(mean(METRO) > 0.5, 1, 0))
            metro = mean(METRO)) %>%
  ggplot(aes(x = income_gap, y = percent_college)) +
    geom_point(aes(size = n#, color = metro, alpha = metro
                   )) +
    facet_wrap(~ cut_number(percent_white, 4)) +
    #geom_smooth() +
    theme_minimal() + 
    labs(x = "Intra-County Income Gap",
         title = "Percentage of county with college degree",
         subtitle = "test")

