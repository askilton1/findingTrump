library(tidyverse)

county_data_rf <- read_csv("data/clean/CC-EST2015-ALLDATA.csv")
# spread manually so that each column is percent of total county population by race, gender, age group ----
AGEGRP_5 <- filter(county_data_rf, AGEGRP == 5) %>% 
  select(contains("MALE"), contains("TOT")) %>% 
  rename_(.dots=setNames(names(.), gsub("MALE", paste0("MALE_", 5), names(.)))) %>% 
  select(contains("MALE"), contains("TOT")) %>%  
  rename_(.dots=setNames(names(.), gsub("POP", paste0("POP_", 5), names(.))))
AGEGRP_6 <- filter(county_data_rf, AGEGRP == 6) %>% 
  rename_(.dots=setNames(names(.), gsub("MALE", paste0("MALE_", 6), names(.)))) %>% 
  select(contains("MALE"), contains("TOT")) %>%  
  rename_(.dots=setNames(names(.), gsub("POP", paste0("POP_", 6), names(.))))
AGEGRP_7 <- filter(county_data_rf, AGEGRP == 7) %>% 
  rename_(.dots=setNames(names(.), gsub("MALE", paste0("MALE_", 7), names(.)))) %>% 
  select(contains("MALE"), contains("TOT")) %>%  
  rename_(.dots=setNames(names(.), gsub("POP", paste0("POP_", 7), names(.))))
AGEGRP_8 <- filter(county_data_rf, AGEGRP == 8) %>% 
  rename_(.dots=setNames(names(.), gsub("MALE", paste0("MALE_", 8), names(.)))) %>% 
  select(contains("MALE"), contains("TOT")) %>%  
  rename_(.dots=setNames(names(.), gsub("POP", paste0("POP_", 8), names(.))))
AGEGRP_9 <- filter(county_data_rf, AGEGRP == 9) %>% 
  rename_(.dots=setNames(names(.), gsub("MALE", paste0("MALE_", 9), names(.)))) %>% 
  select(contains("MALE"), contains("TOT")) %>%  
  rename_(.dots=setNames(names(.), gsub("POP", paste0("POP_", 9), names(.))))
AGEGRP_10 <- filter(county_data_rf, AGEGRP == 10) %>% 
  rename_(.dots=setNames(names(.), gsub("MALE", paste0("MALE_", 10), names(.)))) %>% 
  select(contains("MALE"), contains("TOT")) %>%  
  rename_(.dots=setNames(names(.), gsub("POP", paste0("POP_", 10), names(.))))
AGEGRP_11 <- filter(county_data_rf, AGEGRP == 11) %>% 
  rename_(.dots=setNames(names(.), gsub("MALE", paste0("MALE_", 11), names(.)))) %>% 
  select(contains("MALE"), contains("TOT")) %>%  
  rename_(.dots=setNames(names(.), gsub("POP", paste0("POP_", 11), names(.))))
AGEGRP_12 <- filter(county_data_rf, AGEGRP == 12) %>% 
  rename_(.dots=setNames(names(.), gsub("MALE", paste0("MALE_", 12), names(.)))) %>% 
  select(contains("MALE"), contains("TOT")) %>%  
  rename_(.dots=setNames(names(.), gsub("POP", paste0("POP_", 12), names(.))))
AGEGRP_13 <- filter(county_data_rf, AGEGRP == 13) %>% 
  rename_(.dots=setNames(names(.), gsub("MALE", paste0("MALE_", 13), names(.)))) %>% 
  select(contains("MALE"), contains("TOT")) %>%  
  rename_(.dots=setNames(names(.), gsub("POP", paste0("POP_", 13), names(.))))
AGEGRP_14 <- filter(county_data_rf, AGEGRP == 14) %>% 
  rename_(.dots=setNames(names(.), gsub("MALE", paste0("MALE_", 14), names(.)))) %>% 
  select(contains("MALE"), contains("TOT")) %>%  
  rename_(.dots=setNames(names(.), gsub("POP", paste0("POP_", 14), names(.))))
AGEGRP_15 <- filter(county_data_rf, AGEGRP == 15) %>% 
  rename_(.dots=setNames(names(.), gsub("MALE", paste0("MALE_", 15), names(.)))) %>% 
  select(contains("MALE"), contains("TOT")) %>%  
  rename_(.dots=setNames(names(.), gsub("POP", paste0("POP_", 15), names(.))))
AGEGRP_16 <- filter(county_data_rf, AGEGRP == 16) %>% 
  rename_(.dots=setNames(names(.), gsub("MALE", paste0("MALE_", 16), names(.)))) %>% 
  select(contains("MALE"), contains("TOT")) %>%  
  rename_(.dots=setNames(names(.), gsub("POP", paste0("POP_", 16), names(.))))
AGEGRP_17 <- filter(county_data_rf, AGEGRP == 17) %>% 
  rename_(.dots=setNames(names(.), gsub("MALE", paste0("MALE_", 17), names(.)))) %>% 
  select(contains("MALE"), contains("TOT")) %>%  
  rename_(.dots=setNames(names(.), gsub("POP", paste0("POP_", 17), names(.))))
AGEGRP_18 <- filter(county_data_rf, AGEGRP == 18) %>% 
  rename_(.dots=setNames(names(.), gsub("MALE", paste0("MALE_", 18), names(.)))) %>% 
  select(contains("MALE"), contains("TOT")) %>%  
  rename_(.dots=setNames(names(.), gsub("POP", paste0("POP_", 18), names(.))))

county_data_AGEGRPs <- county_data_rf %>%
  filter(AGEGRP == 5) %>% 
  select(STATEFIPS:AGEGRP) %>% 
  bind_cols(AGEGRP_5, AGEGRP_6, AGEGRP_7, AGEGRP_8, AGEGRP_9, AGEGRP_10, AGEGRP_11, AGEGRP_12, AGEGRP_13, AGEGRP_14, AGEGRP_15, AGEGRP_16, AGEGRP_17, AGEGRP_18) %>% 
  arrange(STATEFIPS, COUNTY)

# join grouped data to original census data -----
election_and_county_data <- read_csv("data/clean/Pres_Election_DatA_2016i.csv") %>% 
  select(STATEFIPS, COUNTY, Trump, Clinton) %>% 
  mutate(vote_difference = Trump - Clinton,
         victor = ifelse(vote_difference > 0, "Trump", "Clinton")) %>% 
  inner_join(county_data_AGEGRPs, by = c("STATEFIPS", "COUNTY")) %>% 
  na.omit #STATEFIPS = 48, COUNTY 301 has some missing values for some reason

# random forest time -----
library(randomForest)
set.seed(1)
randomForestSample_x <- election_and_county_data %>% 
  select(TOT_MALE_5:TOT_POP_18) %>% 
  sample_n(500) 

set.seed(1)
randomForestSample_y <- election_and_county_data %>% 
  select(Trump) %>% 
  sample_n(500) %>% 
  unlist

set.seed(1)
election_county.rf <- randomForest(x = randomForestSample_x,
                                   y = randomForestSample_y, 
                                   importance = TRUE)
tibble(
  "names" = rownames(importance(election_county.rf, type = 1)),
  "percent_IncMSE" = as.numeric(importance(election_county.rf, type = 1))
) %>% 
  arrange(desc(percent_IncMSE)) 


### RACE COMBINATIONS ----
county_data <- read_csv("data/raw/CC-EST2015-ALLDATA.csv",
                        col_types = list(STATE = col_integer(),
                                         COUNTY = col_integer())) %>% 
  filter(AGEGRP >= 5,
         YEAR == 8) %>% 
  group_by(STATE, COUNTY) %>% 
  summarise_at(vars(TOT_POP:HNAC_FEMALE), sum) %>% 
  ungroup %>% 
  mutate_at(vars(TOT_MALE:HNAC_FEMALE), funs(. / TOT_POP)) %>% 
  rename(STATEFIPS = STATE)


election_and_county_data <- read_csv("data/clean/Pres_Election_DatA_2016i.csv") %>% 
  select(STATEFIPS, COUNTY, Trump, Clinton) %>% 
  mutate(vote_difference = Trump - Clinton,
         victor = ifelse(vote_difference > 0, "Trump", "Clinton")) %>% 
  inner_join(county_data, by = c("STATEFIPS", "COUNTY"))

election_and_county_data %>% 
  gather(key, value, TOT_MALE:HNAC_FEMALE) %>% 
  select(vote_difference, TOT_POP, victor, key, value) %>% 
  ggplot(aes(x = value, 
             y = vote_difference,
             size = TOT_POP / 1000)) +
  geom_smooth() +
  facet_wrap(~ key, scales = "free") +
  theme_minimal() +
  scale_color_brewer(type = "qual", palette = "Set1", direction = -1) +
  scale_y_continuous(labels = scales::percent) +
  scale_x_continuous(labels = scales::percent) +
  scale_size_continuous(guide = FALSE) +
  labs(x = "percent of total county population that is...",
       y = "difference in share of vote",
       title = "Relationship between whiteness of county and vote margin",
       subtitle = "A strong relationship between race and political vote exists among older Americans.")

### AGE COMBINATIONS ----
county_data_age <- read_csv("data/raw/CC-EST2015-ALLDATA.csv",
                            col_types = list(STATE = col_integer(),
                                             COUNTY = col_integer())) %>% 
  filter(AGEGRP >= 5,
         YEAR == 8) %>% 
  rename(STATEFIPS = STATE) %>% 
  select(STATEFIPS, COUNTY, AGEGRP, TOT_POP) %>% 
  group_by(STATEFIPS, COUNTY) %>% 
  mutate(prcnt_POP = TOT_POP / sum(TOT_POP))


election_and_county_data_age <- read_csv("data/clean/Pres_Election_DatA_2016i.csv") %>% 
  select(STATEFIPS, COUNTY, Trump, Clinton) %>% 
  mutate(vote_difference = Trump - Clinton,
         victor = ifelse(vote_difference > 0, "Trump", "Clinton")) %>% 
  right_join(county_data_age, by = c("STATEFIPS", "COUNTY"))

election_and_county_data_age %>% 
  mutate(AGEGRP_groups = plyr::mapvalues(AGEGRP,
                                         from = 5:18,
                                         to = c(rep("20-34 years", 3),
                                                rep("35-59 years", 5),
                                                rep("60 years and older", 6)))) %>% 
  ggplot(aes(x = prcnt_POP, 
             y = vote_difference,
             size = TOT_POP / 1000,
             alpha = TOT_POP)) +
  geom_hline(aes(yintercept = 0)) +
  #geom_point(alpha = 1/20, aes(color = victor)) +
  geom_smooth() +
  facet_grid(cut_number(TOT_POP, n = 6) ~ AGEGRP_groups, scales = "free") +
  theme_minimal() +
  scale_color_brewer(type = "qual", palette = "Set1", direction = -1) +
  scale_y_continuous(labels = scales::percent) +
  scale_x_continuous(labels = scales::percent) +
  scale_size_continuous(guide = FALSE) +
  labs(x = "percent of total county population that is...",
       y = "difference in share of vote",
       title = "Relationship between percent of county in age group and vote difference",
       subtitle = "When ~5% of the population in the most populous counties is 60 years and older Clinton and Trump will tie.")

### RACE AND AGE COMBINATIONS ----
county_data <- read_csv("data/raw/CC-EST2015-ALLDATA.csv",
                        col_types = list(STATE = col_integer(),
                                         COUNTY = col_integer())) %>% 
  filter(AGEGRP >= 5,
         YEAR == 8) %>% 
  select(STATE, COUNTY, AGEGRP, TOT_POP, NHWA_MALE) %>% 
  mutate_at(vars(contains("NHWA_")), funs(. / TOT_POP)) %>% 
  rename(STATEFIPS = STATE)


election_and_county_data <- read_csv("data/clean/Pres_Election_DatA_2016i.csv") %>% 
  select(STATEFIPS, COUNTY, Trump, Clinton) %>% 
  mutate(vote_difference = Trump - Clinton,
         victor = ifelse(vote_difference > 0, "Trump", "Clinton")) %>% 
  inner_join(county_data, by = c("STATEFIPS", "COUNTY"))

election_and_county_data %>% 
  mutate(AGEGRP_groups = plyr::mapvalues(AGEGRP,
                                         from = 5:18,
                                         to = c(rep("20-44 years", 5),
                                                rep("45-59 years", 3),
                                                rep("60 - 84 years", 5),
                                                "85 years or older"))) %>% 
  ggplot(aes(x = NHWA_MALE, 
             y = vote_difference,
             size = TOT_POP / 1000,
             color = as.factor(AGEGRP_groups))) +
  geom_smooth() +
  #facet_wrap(~ AGEGRP_groups) +
  theme_minimal() +
  scale_color_brewer(type = "qual", palette = "Set1", direction = -1) +
  scale_y_continuous(labels = scales::percent) +
  scale_x_continuous(labels = scales::percent, limits = c(0.05, 0.5)) +
  scale_size_continuous(guide = FALSE) +
  labs(x = "percent of total county population that is non Hispanic White Male",
       y = "Trump % of total - Clinton % of total",
       title = "Relationship between Whiteness of county and county election result",
       subtitle = "Trump wins by 30% when ~27% of the population of a county is non Hispanic White Male and 85 years or older.")
### WHITENESS POP

county_data <- read_csv("data/clean/CC-EST2015-ALLDATA.csv") %>% 
  group_by(STATEFIPS, COUNTY) %>% 
  summarise_at(vars(TOT_POP, contains("NHWA_")), sum) %>% 
  ungroup %>% 
  transmute(STATEFIPS, COUNTY, TOT_POP, NHWA = NHWA_MALE + NHWA_FEMALE) 

election_and_county_data <- read_csv("data/clean/Pres_Election_DatA_2016i.csv") %>% 
  select(STATEFIPS, COUNTY, Trump, Clinton) %>% 
  inner_join(county_data, by = c("STATEFIPS", "COUNTY"))

election_and_county_data %>% 
  ggplot(aes(x = NHWA, y = vote_difference, color = victor, size = TOT_POP)) +
    geom_point(alpha = 1/2) + 
    theme_minimal() +
    scale_color_brewer(type = "qual", palette = "Set1", direction = -1) +
    scale_y_continuous(labels = scales::percent) +
    scale_x_continuous(labels = scales::percent) +
    scale_size_continuous(guide = FALSE) +
    labs(x = "percent of county that is non-Hispanic White only",
         y = "Margin of Trump lead",
         title = "Trump does best in smaller, less diverse counties",
         subtitle = "While large counties contain more votes, they are outweighed the large number of smaller counties")