temp %>%
  group_by(REGION, STATEFIP, COUNTY) %>%
  summarise_if(is.numeric, mean) %>%
  save(.,file =  "while_in_hawaii.RData")
