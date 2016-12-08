#https://data.ers.usda.gov/reports.aspx?ID=18243
read_csv("data/raw/Education.csv", skip = 4) %>%
  slice(-c(1,2)) %>% 
  select(`FIPS Code`, contains("Percent")) %>% 
  setNames(gsub(pattern = "[[:punct:]]| ", replacement = "_", names(.))) %>%
  setNames(gsub(pattern = "High_school_diploma", replacement = "HSD", names(.), ignore.case = T)) %>%
  setNames(gsub(pattern = "Some_college_or_associate_s_degree|some_college_", replacement = "someCollege", names(.), ignore.case = T)) %>%
  setNames(gsub(pattern = "bachelor_s_degree_or_higher", replacement = "bachelorsOrMore", names(.), ignore.case = T)) %>%
  setNames(gsub(pattern = "with_less_than_a_HSD_|less_than_a_HSD_", replacement = "lessThanHSD", names(.), ignore.case = T)) %>%
  setNames(gsub(pattern = "percent_of_", replacement = "", names(.), ignore.case = T)) %>%
  setNames(gsub(pattern = "___|__", replacement = "_", names(.))) %>%
  rename(FIPS = FIPS_Code) %>% 
  select(FIPS, adults_lessThanHSD_1970:adults_with_a_bachelorsOrMore_2010_2014) %>% 
  gather(key, value, -FIPS) %>% 
  transmute(FIPS, key, percent = value / 100,
            year = gsub('\\D','\\1', key),
            year = as.numeric(substr(year, nchar(year) - 3, nchar(year))),
            year = ifelse(year == 2014, 2010, year)) %>% 
  spread(key, percent, drop = FALSE) %>% 
  unite(someCollege, contains("someCollege")) %>% 
  unite(bachelorsOrMore, contains("bachelorsOrMore"), contains("four_years_of_college_or_higher")) %>% 
  unite(lessThanHSD, contains("lessThanHSD")) %>% 
  unite(HSDonly, contains("HSD_only")) %>% 
  mutate_at(vars(bachelorsOrMore:HSDonly), funs(as.numeric(gsub("NA|_", "", .)))) %>%
  na.omit %>% 
  write_csv("data/clean/Education.csv")
