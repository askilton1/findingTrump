# TK Test - Deleted the extra line and added this sentence.
library(tidyverse)
source("survey_label_mapper.R")
my_db <- src_sqlite("finding_trump.db", create = F)

# STRUCTURE SQL QUERY USING DPLYR
tbl(my_db, sql("select * from ACS_2015")) %>%
  select(STATEFIP, METRO, HHINCOME, POVERTY, RACWHT, LABFORCE) %>%
  filter(METRO != 0,
         LABFORCE != 0,
         POVERTY != 0) %>%
  mutate(RACWHT = RACWHT - 1,
         LABFORCE = LABFORCE - 1,
         POVERTY = POVERTY / 100) %>%
  group_by(STATEFIP, METRO, RACWHT) %>%
  summarise(HHINCOME = median(HHINCOME),
            HHINCOME_sd = sd(HHINCOME),
            POVERTY = median(POVERTY),
            LABFORCE = mean(LABFORCE),
            n = n()) %>%
  ungroup %>%
  
  #EXTRACT DATA FROM DATABASE USING collect()
  
  collect(., n = Inf) %>%
  
  survey_label_mapper() %>%

  #MANIPULATE DATA FOR SPECIFIC GRAPH
  
  arrange(STATEFIP, METRO) %>%
  group_by(STATEFIP, METRO) %>%
  mutate(HHINCOME_white = ifelse(RACWHT == "White", HHINCOME, 0),
         HHINCOME_white = max(HHINCOME_white),
         HHINCOME_not_white = ifelse(RACWHT == "not White", HHINCOME, 0),
         HHINCOME_not_white = max(HHINCOME_not_white),
         LABFORCE_white = ifelse(RACWHT == "White", LABFORCE, 0),
         LABFORCE_white = max(LABFORCE_white),
         LABFORCE_not_white = ifelse(RACWHT == "not White", LABFORCE, 0),
         LABFORCE_not_white = max(LABFORCE_not_white)) %>% 
  ggplot() +
    geom_segment(aes(x = HHINCOME_white, xend = HHINCOME_not_white, y = LABFORCE_white, yend = LABFORCE_not_white), size = .1) +
    geom_point(aes(x = HHINCOME, y = LABFORCE, size = n, color = RACWHT, alpha = 0.5)) +
    facet_wrap(~ METRO, scales = "free") + 
    theme_minimal() + 
    xlab("Household Income") + 
    ylab("Percent in Labor Force") + 
    scale_size(guide = FALSE) + 
    scale_alpha(guide = FALSE) +
    scale_color_manual(name = "Race",
                       #colors from: http://www.cookbook-r.com/Graphs/Colors_(ggplot2)/
                       values = c("#000000", "#D55E00")) +
    ggtitle("In Most States Whites Are Much Better Off Than Non Whites") + 
    theme(legend.position = "bottom")
ggsave("plots/output/whites_better_off_by_region_type.pdf")
