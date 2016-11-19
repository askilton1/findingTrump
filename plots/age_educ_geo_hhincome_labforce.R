library(tidyverse)
my_db <- src_sqlite("finding_trump.db", create = F)

#METRO:
##0: not identifiable
##1: not in metro area
##2: In metro area, central/principal city
##3: In metro area, outside central/principal city
##4: Central/Principal city status unknown

#POVERTY
## 000 = N/A
## 001 = 1% or less of poverty threshold
## 501 = 501% or more of poverty threshold

#RACWHT
## 1: No
## 2: Yes

# STRUCTURE SQL QUERY USING DPLYR
# AGE

#LABFORCE
##0: N/A
##1: No, not in the labor force
##2: Yes, in the labor force

# HCOVANY
##1: No health insurance coverage
##2: With health insurance coverage

# EDUC
##00 N/A or no schooling
##01 Nursery school to grade 4
##02 Grade 5, 6, 7, or 8
##03 Grade 9
##04 Grade 10
##05 Grade 11
##06 Grade 12
##07 1 year of college
##08 2 years of college
##09 3 years of college
##10 4 years of college
##11 5+ years of college

# STRUCTURE SQL QUERY USING DPLYR
# Capped income at 250,000
tbl(my_db, sql("select a.SERIAL, a.METRO, a.AGE, a.HHINCOME, a.EDUC, b.HHEDUC 
               from ACS_2015 a
               left outer join (
                                 select SERIAL, max(EDUC) as HHEDUC
                                 from ACS_2015 
                                 group by SERIAL) b
               on a.SERIAL = b.SERIAL
               where HHINCOME < 2000000")) %>%
  #EXTRACT DATA FROM DATABASE USING collect()
  collect(., n = Inf) -> temp 

#do these outcomes match the way you've grouped education levels above?
#most common groupings are: less than HSD, HSD, Some College, Bachelors, More than Bachelors

temp %>%
  group_by(HHEDUC) %>%
  summarise(n = n(), `median income` = median(HHINCOME)) %>%
  ggplot(aes(x = as.factor(HHEDUC), y = `median income`, size = n)) + 
  geom_point(stat = "identity")

temp %>%
  sample_n(100000) %>%
  ggplot(aes(x = as.factor(HHEDUC), y = HHINCOME)) +
  geom_boxplot()

############################


#CLEAN DATA EXTRACTED FROM DATABASE
temp %>%
  mutate(#map abbreviation
    HHEDUC = plyr::mapvalues(HHEDUC, 0:11, c("N/A or no schooling",
                                             "Nursery school to grade 4",
                                             "Grade 5, 6, 7, or 8",
                                             "Grade 9",
                                             "Grade 10",
                                             "Grade 11",
                                             "Grade 12",
                                             "1 year of college",
                                             "2 years of college",
                                             "3 years of college",
                                             "4 years of college",
                                             "5+ years of college"))) -> temp

temp %>%
  #MANIPULATE DATA FOR SPECIFIC GRAPH
  ggplot(aes(x = AGE , y = HHINCOME / 1000, color = HHEDUC)) +
  geom_smooth() +
  facet_wrap(~ HHEDUC, scales = "free") + 
  theme_minimal() + 
  theme(legend.position = "none") +
  xlab("Age") + 
  ylab("Household Income in thousands") +
  ggtitle("Household Income by Age, by Education") + 
  theme(legend.position = "bottom") +
  scale_y_continuous(labels = scales::dollar)
