# TK Test - Deleted the extra line and added this sentence.
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
tbl(my_db, sql("select * from ACS_2015")) %>%
  select(AGE, LABFORCE, HCOVANY, EDUC, HHINCOME) %>%
  filter(AGE >= 018,
         LABFORCE != 0,
         EDUC != 0) %>%
  mutate(LABFORCE = LABFORCE - 1,
         HCOVANY = HCOVANY -1) %>%
  summarise(HCOVANY = mean(HCOVANY),
            HHINCOME = median(HHINCOME)) %>%

  #EXTRACT DATA FROM DATABASE USING collect()
  
  collect %>%
  
  #CLEAN DATA EXTRACTED FROM DATABASE
  mutate(#map abbreviation
    EDUC = ifelse(EDUC >= 07, 3, EDUC),
    EDUC = ifelse(EDUC >= 05 & EDUC < 07, 2, EDUC),
    EDUC = ifelse(EDUC >= 03 & EDUC < 05, 1, EDUC),
    EDUC = ifelse(EDUC < 03, 0, EDUC),
    EDUC = plyr::mapvalues(EDUC, 0:3, c("Less than middle school education",
                                        "Some high school education",
                                        "High school education",
                                        "College education")),
    HCOVANY = plyr::mapvalues(HCOVANY, 0:1, c("No health insurance coverage", 
                                               "With health insurance coverage"))
  ) %>%
  
  #MANIPULATE DATA FOR SPECIFIC GRAPH
  
  arrange(EDUC) %>%
  group_by(EDUC) %>%
   ggplot() +
    geom_point(aes(x = HHINCOME, y = HCOVANY, size = n, alpha = 0.5)) +
    facet_wrap(~ EDUC, scales = "free") + 
    theme_minimal() + 
    xlab("Household Income") + 
    ylab("Percent with Health Insurance") + 
    scale_size(guide = FALSE) + 
    scale_alpha(guide = FALSE) +
#    ggtitle("In Most States Whites Are Much Better Off Than Non Whites") + 
    theme(legend.position = "bottom")
#gsave("plots/output/whites_better_off_by_region_type.pdf")
