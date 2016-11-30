#http://factfinder.census.gov/faces/tableservices/jsf/pages/productview.xhtml?src=bkmk
read_csv("data/raw/county_density.csv", skip = 1, 
         col_types = cols_only(`Target Geo Id` = col_character(),
                               `Density per square mile of land area - Population` = col_double())) %>% 
  filter(nchar(`Target Geo Id`) == 14) %>% 
  transmute(STATEFIPS = as.numeric(substr(`Target Geo Id`, start = 10, stop = 11)),
            COUNTY = as.numeric(substr(`Target Geo Id`, start = 12, stop = 14)),
            people_per_sq_mile = `Density per square mile of land area - Population`) %>% 
  write_csv("data/clean/county_density.csv")