library(tidyverse)
source("survey_label_mapper.R")
my_db <- src_sqlite("finding_trump.db", create = F)

# STRUCTURE SQL QUERY USING DPLYR
# Capped income at 250,000
tbl(my_db, sql("select a.SERIAL, a.METRO, a.AGE, a.RELATE, a.HHINCOME, b.HHEDUC 
               from ACS_2013_5year a
               left outer join (
                                 select SERIAL, max(EDUC) as HHEDUC
                                 from ACS_2013_5year 
                                 group by SERIAL) b
               on a.SERIAL = b.SERIAL
               where HHINCOME < 2000000 and EDUC != 0")) %>%
  #EXTRACT DATA FROM DATABASE USING collect()
  collect(., n = Inf) -> temp 

temp %>%
  sample_n(500000) %>% 
  group_by(hh_gradeattd) %>%
  summarise(n = n())

sum(df2$hh_gradeattd == 53)
#CLEAN DATA EXTRACTED FROM DATABASE

  mutate(HHEDUC = plyr::mapvalues(HHEDUC, 1:11, EDUC_labels),
         METRO = plyr::mapvalues(METRO, 0:4, METRO_labels),
         Child = ifelse(RELATE == 3 | RELATE == 4 | RELATE == 9, 1, 0),
         Head = ifelse(RELATE == 1, "head of household", "not head of household")) -> temp

temp %>%
#PLOT!
  filter(RELATE == 1) %>%
  ggplot(aes(x = AGE , y = HHINCOME / 1000, color = HHEDUC)) +
    geom_smooth() +
    facet_wrap( ~ METRO, scales = "free_x") + 
    theme_minimal() + 
    theme(legend.position = "none") +
    xlab("Age of Head of Household") + 
    ylab("Household Income in thousands") +
    ggtitle("Head of Household Household Income by Age, by Education") + 
    theme(legend.position = "bottom") +
    scale_y_continuous(labels = scales::dollar)