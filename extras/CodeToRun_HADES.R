# ============================================================
# Connection set up
# ============================================================

library(DatabaseConnector)

## Connection set up

# CM Execution Settings:
server <- ""
port <- ""
dbms <- ""
user <- ""
password <- ""
pathToDriver <- "~/drivers"

workDatabaseSchema <- "" 
cdmDatabaseSchema  <- ""
Database_Name <- ""
cohortTable <- paste(Database_Name, '_ASTHMA_STUDYATHON_', format(Sys.Date(), "%m%d%Y"), sep = "")

#List Execution Settings:
executionSettings <- list(
  cohortTable = cohortTable,
  cdmDatabaseSchema = cdmDatabaseSchema,
  workDatabaseSchema = workDatabaseSchema,
  connectionDetails = DatabaseConnector::createConnectionDetails(
    dbms   =   dbms,
    server =   server,
    #connectionString = server,
    user   =   user,
    password = password,
    port     = port,
    pathToDriver = pathToDriver
  ),
  cohortDatabaseSchema = workDatabaseSchema,
  sensitive = TRUE
)

#Check Redshift Connection
con <- connect(executionSettings$connectionDetails)
cohortDatabaseSchema <- executionSettings$cohortDatabaseSchema
cdmDatabaseSchema <- executionSettings$cdmDatabaseSchema
cohortTable <-executionSettings$cohortTable


## Execute analysis
source("R/HADES/RunAnalysis.R")