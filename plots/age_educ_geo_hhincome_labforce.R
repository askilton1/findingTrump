library(tidyverse)
my_db <- src_sqlite("finding_trump.db", create = F)

#METRO:
##0: not identifiable
##1: not in metro area
##2: In metro area, central/principal city
##3: In metro area, outside central/principal city
##4: Central/Principal city status unknown

METRO_labels <- c("not identifiable",
                  "not in metro area",
                  "In metro area",
                  "In metro area",
                  "In metro area")

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

EDUC_labels <- c(#"N/A or no schooling",
                "Less than high school",
                "Less than high school",
                "Less than high school",
                "Less than high school",
                "Less than high school",
                "High School",
                "Some College",
                "Some College",
                "Some College",
                "Bachelors Degree",
                "Postgraduate study")


# STRUCTURE SQL QUERY USING DPLYR
# Capped income at 250,000
tbl(my_db, sql("select a.SERIAL, a.METRO, a.RACE, a.SEX, a.AGE, a.RELATE, a.HHINCOME, a.EDUC, b.HHEDUC 
               from ACS_2015 a
               left outer join (
                                 select SERIAL, max(EDUC) as HHEDUC
                                 from ACS_2015 
                                 group by SERIAL) b
               on a.SERIAL = b.SERIAL
               where HHINCOME < 2000000 and EDUC != 0")) %>%
  #EXTRACT DATA FROM DATABASE USING collect()
  collect(., n = Inf) -> temp 

#CLEAN DATA EXTRACTED FROM DATABASE
temp %>%
  mutate(#map abbreviation
    HHEDUC = plyr::mapvalues(HHEDUC, 1:11, EDUC_labels),
    METRO = plyr::mapvalues(METRO, 0:4, METRO_labels),
    Child = ifelse(RELATE == 3 | RELATE == 4 | RELATE == 9, 1, 0),
    Head = ifelse(RELATE == 1, 1, 0)) -> temp

temp %>%
  filter(#(Child == 1 & AGE <= 50) | Child == 0,
         RELATE == 1) %>%
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