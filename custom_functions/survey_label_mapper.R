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
  
  if("RACE" %in% names(df)) df <- mutate(df, RACE = plyr::mapvalues(RACE, 1:9, c("White",
                                                                                 "Black",
                                                                                 "American Indian",
                                                                                 #rep("Asian", 3),
                                                                                 rep("Other", 6))))
  
  # if("REGION" %in% names(df)) df <- mutate(df, REGION = plyr::mapvalues(REGION, c(11:13, 21:23, 31:34, 
  #                                                                                 41:43, 91:92, 97, 99), c("New England",
  #                                                                                                          "Middle Atlantic",
  #                                                                                                          "Mixed Northeast",
  #                                                                                                          "East North Central",
  #                                                                                                          "West North Central",
  #                                                                                                          "Mixed Midwest",
  #                                                                                                          "South Atlantic",
  #                                                                                                          "East South Central",
  #                                                                                                          "West South Central",
  #                                                                                                          "Mixed Southern",
  #                                                                                                          "Mountain",
  #                                                                                                          "Pacific",
  #                                                                                                          "Mixed Western",
  #                                                                                                          "Military/Miltary reservations",
  #                                                                                                          "PUMA boundaries cross state lines",
  #                                                                                                          "State not identified",
  #                                                                                                          "Not identified")))
  
  if("REGION" %in% names(df)) df <- mutate(df, REGION = plyr::mapvalues(REGION, c(11:13, 21:23, 31:34, 
                                                                                  41:43, 91:92, 97, 99), c(rep("Northeast", 3),
                                                                                                           rep("Midwest", 3),
                                                                                                           rep("South", 4),
                                                                                                           rep("West", 3),
                                                                                                           rep("Unknown", 4))
                                                                        ))

  ##2 Midwest
  ##3 South 
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
  if("STATEFIP" %in% names(df)) df <- mutate(df, STATEFIP = plyr::mapvalues(STATEFIP, c(1:2, 4:6, 8:13, 15:42, 44:51, 53:56), 
                                                                            c("AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DL", "DC", "FL",
                                                                              "GA", "HI", "ID", "IL", "IN", "IA", "KA", "KY", "LA",
                                                                              "ME", "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE",
                                                                              "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "OH", "OK",
                                                                              "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VT",
                                                                              "VA", "WA", "WV", "WI", "WY"))) 
  return(df)
}