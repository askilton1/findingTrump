library(checkpoint) #we will have to use a checkpoint until RSQLServer package updates to accomodate new version of dplyr
checkpoint("2016-05-01", checkpointLocation = tempdir()); "y"
#library(RSQLServer)
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
DBI::dbListTables(aw)
DBI::dbListFields(aw, 'AFS')


# Fetch all results
res <- dbSendQuery(aw, 'SELECT TOP 10 * FROM dbo.AFS')
dbFetch(res)
dbClearResult(res)

# Disconnect from DB
dbDisconnect(aw)

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
