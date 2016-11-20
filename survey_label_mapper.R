survey_label_mapper <- function(df){
  library(dplyr)
  
  #METRO:
  ##0: not identifiable
  ##1: not in metro area
  ##2: In metro area, central/principal city
  ##3: In metro area, outside central/principal city
  ##4: Central/Principal city status unknown
  
  if("METRO" %in% names(df)) df <- mutate(df, METRO = plyr::mapvalues(METRO, 0:4, c("not identifiable",
                                                                                    "not in metro area",
                                                                                    rep("In metro area", 3)))) 
  #POVERTY
  ## 000 = N/A
  ## 001 = 1% or less of poverty threshold
  ## 501 = 501% or more of poverty threshold
  
  #RACWHT
  ## 1: No
  ## 2: Yes
  
  if("RACWHT" %in% names(df)) df <- mutate(df, RACWHT = RACWHT - 1)
  
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
   
  if("EDUC" %in% names(df)) df <- mutate(df, EDUC = plyr::mapvalues(EDUC, 0:11, c("N/A or no schooling",
                                                                                  rep("less than high school", 5),
                                                                                  "High School",
                                                                                  rep("some college", 3),
                                                                                  "Bachelors Degree",
                                                                                  "Postgraduate study")))
  
  if("HHEDUC" %in% names(df)) df <- mutate(df, HHEDUC = plyr::mapvalues(HHEDUC, 0:11, c("N/A or no schooling",
                                                                                        rep("less than high school", 5),
                                                                                        "High School",
                                                                                        rep("some college", 3),
                                                                                        "Bachelors Degree",
                                                                                        "Postgraduate study")))
  ###need to fill in gaps in STATEFIP
  if("STATEFIP" %in% names(df)) df <- mutate(df, STATEFIP = ifelse(STATEFIP >= 53, STATEFIP - 1, STATEFIP),
                                                 STATEFIP = ifelse(STATEFIP >= 44, STATEFIP - 1, STATEFIP),
                                                 STATEFIP = ifelse(STATEFIP >= 15, STATEFIP - 1, STATEFIP),
                                                 STATEFIP = ifelse(STATEFIP >= 8, STATEFIP - 1, STATEFIP),
                                                 STATEFIP = ifelse(STATEFIP >= 4, STATEFIP - 1, STATEFIP),
                                                 #map abbreviation
                                                 STATEFIP = plyr::mapvalues(STATEFIP, 1:51, c(state.abb[1:10], "DC", state.abb[11:50]))) 
  return(df)
}