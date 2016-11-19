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

METRO_numbers <- c(0, 0, 1, 1, 1)

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

#on county level data
# STRUCTURE SQL QUERY USING DPLYR
# Capped income at 250,000
tbl(my_db, sql("select a.SERIAL, a.STATEFIP, a.COUNTY, a.METRO, a.RACWHT, a.SEX, a.AGE, a.RELATE, a.HHINCOME, a.EDUC, b.HHEDUC 
               from ACS_2015 a
               left outer join (
               select SERIAL, max(EDUC) as HHEDUC
               from ACS_2015 
               group by SERIAL) b
               on a.SERIAL = b.SERIAL
               where HHINCOME < 2000000 and EDUC != 0")) %>%
  #EXTRACT DATA FROM DATABASE USING collect()
  collect(., n = Inf) %>%
  
  #CLEAN DATA EXTRACTED FROM DATABASE
  mutate(HHEDUC = plyr::mapvalues(HHEDUC, 1:11, EDUC_labels),
         METRO = plyr::mapvalues(METRO, 0:4, METRO_numbers),
         Child = ifelse(RELATE == 3 | RELATE == 4 | RELATE == 9, 1, 0),
         Head = ifelse(RELATE == 1, "head of household", "not head of household"),
         RACWHT = RACWHT - 1,
         STATEFIP = ifelse(STATEFIP >= 53, STATEFIP - 1, STATEFIP),
         STATEFIP = ifelse(STATEFIP >= 44, STATEFIP - 1, STATEFIP),
         STATEFIP = ifelse(STATEFIP >= 15, STATEFIP - 1, STATEFIP),
         STATEFIP = ifelse(STATEFIP >= 8, STATEFIP - 1, STATEFIP),
         STATEFIP = ifelse(STATEFIP >= 4, STATEFIP - 1, STATEFIP),
         #map abbreviation
         STATEFIP = plyr::mapvalues(STATEFIP, 1:51, c(state.abb[1:10], "DC", state.abb[11:50]))) -> temp

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

