library(tidyverse)
mortality <- read_tsv("data/clean/Compressed Mortality, 1999-2014.txt")

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

insurance <- read_csv("data/clean/County_Data_2016_health_insurance.csv")

election %>% 
  inner_join(unemployment) %>% 
  inner_join(pop) %>%
  inner_join(mortality) %>% 
  inner_join(insurance) %>% 
  mutate(STATEFIPS = as.factor(STATEFIPS)) %>% 
  na.omit %>% 
  select(-Civilian_labor_force_2015, -county_name, -STATEABB, -Clinton, -COUNTY) %>% 
  ggplot(aes(x = maleSuicidesPer100k, 
             y = vote_difference, 
             color = victor, 
             size = TOT_POP)) +
    geom_point(alpha = 1/2) + 
    facet_wrap(~cut_number(TOT_POP, 9)) +
    theme_minimal() +
    scale_color_brewer(type = "qual", palette = "Set1", direction = -1) +
    scale_y_continuous(labels = scales::percent) +
    #scale_x_continuous(labels = scales::percent) +
    scale_size_continuous(guide = FALSE) +
    labs(x = "Male suicides per 100k people",
         y = "Margin of Trump lead",
         title = "Male Suicides Highest in Small Towns",
         subtitle = "Top left shows counties with lowest population, bottom right shows counties with highest population")
ggsave("plots/output/male_suicides.pdf")