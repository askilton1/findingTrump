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

#LABFORCE
##0: N/A
##1: No, not in the labor force
##2: Yes, in the labor force

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
  
  collect %>%
  
  #CLEAN DATA EXTRACTED FROM DATABASE
  ###need to fill in gaps in STATEFIP
  mutate(STATEFIP = ifelse(STATEFIP >= 53, STATEFIP - 1, STATEFIP),
         STATEFIP = ifelse(STATEFIP >= 44, STATEFIP - 1, STATEFIP),
         STATEFIP = ifelse(STATEFIP >= 15, STATEFIP - 1, STATEFIP),
         STATEFIP = ifelse(STATEFIP >= 8, STATEFIP - 1, STATEFIP),
         STATEFIP = ifelse(STATEFIP >= 4, STATEFIP - 1, STATEFIP),
         #map abbreviation
         STATEFIP = plyr::mapvalues(STATEFIP, 1:51, c(state.abb[1:10], "DC", state.abb[11:50])),
         METRO = plyr::mapvalues(METRO, 1:4, c("Not in metro area", 
                                               "In metro area, central/principal city",
                                               "In metro area, outside central/principal city",
                                               "Central/Principal city status unknown")),
         RACWHT = as.factor(plyr::mapvalues(RACWHT, 0:1, c("not White", "White")))
  ) %>%
  
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