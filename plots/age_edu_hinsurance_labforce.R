library(tidyverse)
my_db <- src_sqlite("finding_trump.db", create = F)

#METRO:
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
tbl(my_db, sql("select * from ACS_2015")) %>%
  select(SERIAL, AGE, HHINCOME, EDUC) %>%
         #3: some college or more
  mutate(EDUC = ifelse(EDUC >= 7, 3,
                       #2: grades 11 and 12
                       ifelse(EDUC < 7 & EDUC >= 5, 2,
                              #1: grades 10, 9
                              ifelse(EDUC < 5 & EDUC >= 3, 1,
                                     #0: grade 9 and below
                                     ifelse(EDUC < 3, 0, 0))))) %>%
  
  #EXTRACT DATA FROM DATABASE USING collect()
  collect(., n = Inf) -> temp

#by saving file we don't have to wait for each query to complete
save(temp, file = "image/aehl_table.RData")

#CLEAN DATA EXTRACTED FROM DATABASE
load("image/aehl_table.RData") 
temp %>%
  mutate(#map abbreviation
   EDUC = plyr::mapvalues(EDUC, 0:3, c("Less than middle school education",
                                        "Some high school education",
                                        "High school education",
                                        "College education"))) -> temp

temp %>%
  #MANIPULATE DATA FOR SPECIFIC GRAPH
  #arrange(EDUC) %>%
  #group_by(EDUC) %>%
   ggplot(aes(x = AGE , y = HHINCOME / 1000)) +
    #geom_density() +
    geom_smooth() +
    scale_size(guide = FALSE) + 
    scale_alpha(guide = FALSE) +
    facet_wrap(~ EDUC, scales = "free") + 
    theme_minimal() + 
    xlab("Age") + 
    ylab("Household Income")
  #  scale_size(guide = FALSE) + 
  #  scale_alpha(guide = FALSE) +
    ggtitle("Household Income by Age, by Education") + 
    theme(legend.position = "bottom")
