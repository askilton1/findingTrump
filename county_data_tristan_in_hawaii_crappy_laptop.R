temp %>%
  group_by(REGION, STATEFIP, COUNTY) %>%
  mutate(college = ifelse(HHEDUC == "Bachelors Degree" | HHEDUC == "Postgraduate study", 1, 0),
         METRO = ifelse(METRO == "In metro area", 1, 0)) %>%
  summarise(percent_white = mean(RACWHT), average_age = mean(AGE), median_hhincome = median(HHINCOME), percent_college_degree = mean(college), county_pop = n()) %>%
  save(.,file =  "while_in_hawaii.RData")
