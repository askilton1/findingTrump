unemployment <- read_csv("data/clean/Unemployment.csv") %>% 
  mutate(Unemployment_rate_2015 = Unemployment_rate_2015 / 100)

election <- read_csv("data/clean/Pres_Election_DatA_2016i.csv")

pop <- read_csv("data/clean/CC-EST2015-ALLDATA.csv", col_types = cols_only(STATEFIPS = col_integer(),
                                                                           COUNTY = col_integer(),
                                                                           TOT_POP = col_integer(),
                                                                           NHWA_MALE = col_double(),
                                                                           NHWA_FEMALE = col_double())) %>% 
  group_by(STATEFIPS, COUNTY) %>% 
  mutate(NHWA = NHWA_MALE + NHWA_FEMALE,
         NHWA = TOT_POP * NHWA) %>% 
  summarise_at(vars(TOT_POP, NHWA), sum) %>% 
  mutate(NHWA = NHWA / TOT_POP)

random_forest_x <- election %>% 
  inner_join(unemployment) %>% 
  inner_join(pop) %>%
  mutate(STATEFIPS = as.factor(STATEFIPS)) %>% 
  na.omit %>% 
  select(-Civilian_labor_force_2015, -county_name, -STATEABB, -Clinton, -COUNTY) %>% 
  select(-Trump)

random_forest_y <- election %>% 
  inner_join(unemployment) %>% 
  inner_join(pop) %>%
  mutate(STATEFIPS = as.factor(STATEFIPS)) %>% 
  na.omit %>% 
  select(Trump) %>% 
  unlist

library(randomForest)
rf <- randomForest(x = random_forest_x, y = random_forest_y, importance = T)
importance(rf)