library(tidyverse)
source("survey_label_mapper.R")
my_db <- src_sqlite("finding_trump.db", create = F)

#on county level data
# STRUCTURE SQL QUERY USING DPLYR
# Capped income at 250,000
tbl(my_db, sql("select a.YEAR, a.DATANUM, a.SERIAL, a.STATEFIP, a.COUNTY, a.REGION, a.METRO, a.RACWHT, a.AGE, a.HHINCOME, b.HHEDUC 
               from ACS_2013_5year a
               left outer join (
               select YEAR, DATANUM, SERIAL, max(EDUC) as HHEDUC
               from ACS_2013_5year 
               group by SERIAL) b
               on (a.SERIAL = b.SERIAL AND a.YEAR = b.YEAR AND a.DATANUM = b.DATANUM)
               where HHINCOME < 2000000 and EDUC != 0")) %>%
  #EXTRACT DATA FROM DATABASE USING collect()
  collect(., n = Inf) %>%
  survey_label_mapper() -> temp

temp %>%
  filter(COUNTY != 0) %>%
  group_by(REGION, STATEFIP, COUNTY) %>%
  mutate(college = ifelse(HHEDUC == "Bachelors Degree" | HHEDUC == "Postgraduate study", 1, 0),
         METRO = ifelse(METRO == "In metro area", 1, 0)) %>%
  summarise(n = n() / 1000,
            percent_white = mean(RACWHT),
            percent_college = mean(college),
            income_gap = as.numeric(summary(HHINCOME)[5] - summary(HHINCOME)[2]) / 1000,
            #metropolitan = as.factor(ifelse(mean(METRO) > 0.5, 1, 0))
            metro = mean(METRO)) %>%
  ggplot(aes(x = percent_college, y = income_gap, alpha = 0.5, size = n)) +
    geom_point() +
    geom_smooth() +
    facet_wrap(~ REGION) +
    theme_minimal() + 
    theme(legend.position = "minimal") +
    labs(y = "Intra-county income gap, in thousands of dollars",
         x = "Percent of county with college degree",
         title = "Counties with higher college education rates have higher income disparity",
         subtitle = "This correlation is especially strong in the Pacific, Middle Atlantic, and South Atlantic")
ggsave("plots/output/college_degree_and_income_gap_by_region.pdf")
