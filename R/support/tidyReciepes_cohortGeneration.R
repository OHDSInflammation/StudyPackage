readRenviron("~/.env")
install.packages('remotes')
remotes::install_github('OdyOSG/tidyOhdsiRecipies', force = T)
install.packages("fs")
library(tidyOhdsiRecipies)
library(DatabaseConnector)
library(Capr)

## create connection 
# CM Execution Settings:
Database_Name <- 'USA_AMBEMR'

#List Execution Settings:
executionSettings <- list(
  cohortTable = paste(Database_Name, '_ASTHMA_STUDYATHON_', format(Sys.Date(), "%m%d%Y"), sep = ""),
  cdmDatabaseSchema = 'EXT_OMOPV5_USA_AMBEMR.FULL_LATEST_OMOP_V5',
  workDatabaseSchema = "PA_USA_AMBEMR.STUDY_REFERENCE" ,
  connectionDetails = DatabaseConnector::createConnectionDetails(
    dbms   =   "snowflake",
    #server =   server,
    connectionString = paste0(Sys.getenv("OMOP_PA_SERVER"),"&db=PA_USA_AMBEMR&schema=STUDY_REFERENCE"),
    user   =   Sys.getenv("SNOWFLAKE_USER"),
    password = "",
    port     = "443",
    pathToDriver = "~/drivers"
  ),
  cohortDatabaseSchema = 'EXT_OMOPV5_USA_AMBEMR.FULL_LATEST_OMOP_V5',
  sensitive = TRUE
)

con <- connect(executionSettings$connectionDetails)


## getting concepts from cohort json 
target_cohort_dir <- here::here("inst", "targets", "cohorts")


## creating cohort definition set 
cohortsToCreate <- tidyOhdsiRecipies::createCohortDefinitionSet(target_cohort_dir)


# run the cohorts from generation set on the writable schema 
CohortGenerator::runCohortGeneration(connectionDetails =  executionSettings$connectionDetails ,
                                     cdmDatabaseSchema =  executionSettings$cdmDatabaseSchema,
                                     tempEmulationSchema = getOption("sqlRenderTempEmulationSchema"),
                                     cohortDatabaseSchema = executionSettings$workDatabaseSchema,
                                     cohortTableNames = CohortGenerator::getCohortTableNames(executionSettings$cohortTable),
                                     cohortDefinitionSet = generationSet,
                                     outputFolder = paste (Database_Name, "_results", sep = ""))


