library(checkpoint) #we will have to use a checkpoint until RSQLServer package updates to accomodate new version of dplyr
checkpoint("2016-05-01", checkpointLocation = tempdir()); "y"

#############
# DBI
#############

# Note we do not attach the RSQLServer package.
library(DBI)
# Connect to AW server in ~/sql.yaml
# This is an Azure hosted SQL Server database provided at someone else's 
# expense. Feel free to tip them some:
# http://sqlblog.com/blogs/jamie_thomson/archive/2012/03/27/adventureworks2012-now-available-to-all-on-sql-azure.aspx
aw <- DBI::dbConnect(RSQLServer::SQLServer(), "AW", database = "skilton_db")
# RSQLServer only returns tables with type TABLE and VIEW.
# But this DB has lots of useless tables. 
# DBI::dbListTables(aw)
# DBI::dbListFields(aw, 'AFS')


# Fetch all results
library(dplyr)
source("survey_label_mapper.R")

south <- dbSendQuery(aw, 'SELECT * FROM dbo.census_hhold
                          WHERE REGION >= 30 and REGION < 40') %>% #The south
            dbFetch() %>%
            survey_label_mapper %>%
            tbl_df

# Disconnect from DB
dbDisconnect(aw)

#needed to install ggplot 2.2
library(devtools)
install_github("cran/scales")
install_github("hadley/lazyeval")
install_github("hadley/tibble")
install_github("tidyverse/ggplot2") 
library(tibble)
library(ggplot2)

south %>%
  filter(RACE != "American Indian",
         RACE != "Other") %>% 
  group_by(STATEFIP, COUNTY, RACE) %>%
  summarise(n = n(), 
            college = mean(hh_College_Degree),
            income = median(HHINCOME) / 1000) %>%
  ggplot(aes(x = college, y = income, size = n, alpha = 0.5, color = RACE)) +
    geom_point(stat = "identity") + 
    facet_wrap(~STATEFIP) + 
    theme_minimal() + 
    scale_y_continuous(labels = scales::dollar) +
    scale_x_continuous(labels = scales::percent) +
    scale_color_manual(values = c("black", "red")) +
    labs(y = "Household Income in Thousands",
         x = "Percent of Households With College Degree",
         title = "Relationship Between Household Income and College Education in County-Race Groups in the South",
         subtitle = "In most counties Whites outperform Blacks in both household income and college degree attainment.") +
    guides(size = FALSE, alpha = FALSE) +
    theme(legend.position = c(0.9, 0.1)) 
    

library(ineq)
south %>% 
  # filter(RACE == "White") %>%
  group_by(STATEFIP, COUNTY) %>% 
  summarise(inequality = ineq(HHINCOME, type = "Gini")) %>% 
  ungroup %>% 
  arrange(desc(inequality))
  

south %>% 
  filter(STATEFIP == "WV") %>% 
  group_by(COUNTY) %>% 
  summarise(n = n())
  
south %>%
  group_by(hh_adult_men_not_in_labor_force) %>%
  filter(hh_adult_men_not_in_labor_force < 4, 
         hh_Female_Head_of_Household == 0) %>% #female headed households
  summarise_each(funs(round(mean(.), 2)), HHINCOME, hh_White:hh_labor_force)
#############
# dplyr
#############

# Note we do not attach the RSQLServer package here either
library(dplyr)
aw <- RSQLServer::src_sqlserver("AW", database = "skilton_db")
# Alas, cannot easily call tables in non-default schema
# Workaround is to SELECT whole table
# https://github.com/hadley/dplyr/issues/244
# Retrieves and prints first ten rows of table only
(dept <- tbl(aw, sql("SELECT * FROM dbo.AFS")))
# The following is translated to SQL and executed on the server. Only
# the first ten records are retrieved and printed to the REPL.
rd <- dept %>% 
  filter(GroupName == "Research and Development") %>% 
  arrange(Name)
# Bring the full data set back to R
collect(rd)
