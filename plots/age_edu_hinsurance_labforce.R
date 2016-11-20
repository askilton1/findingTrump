library(tidyverse)
source("survey_label_mapper.R")
my_db <- src_sqlite("finding_trump.db", create = F)

# STRUCTURE SQL QUERY USING DPLYR
# Capped income at 250,000
tbl(my_db, sql("select a.SERIAL, a.AGE, a.HHINCOME, b.HHEDUC 
                from ACS_2015 a
                left outer join (
                  select SERIAL, max(EDUC) as HHEDUC
                  from ACS_2015 
                  group by SERIAL) b
                  on a.SERIAL = b.SERIAL
                where HHINCOME < 2000000")) %>%
  #EXTRACT DATA FROM DATABASE USING collect()
  collect(., n = Inf) %>%
  survey_label_mapper() -> temp 

temp %>%
  #MANIPULATE DATA FOR SPECIFIC GRAPH
  ggplot(aes(x = AGE , y = HHINCOME / 1000)) +
    geom_smooth() +
    facet_wrap(~ HHEDUC, scales = "free") + 
    theme_minimal() + 
    theme(legend.position = "none") +
    xlab("Age") + 
    ylab("Household Income in thousands") +
    ggtitle("Household Income by Age, by Education") + 
    theme(legend.position = "bottom") +
    scale_y_continuous(labels = scales::dollar)