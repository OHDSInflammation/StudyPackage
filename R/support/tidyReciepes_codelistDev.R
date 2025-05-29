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

### Code list for cohort development 

## 1. code list from JSON 
codelist_dir <- here::here("inst", "codeLists")
## code list from code json 
asthma_json_codes <- Capr::readConceptSet(path = paste0(codelist_dir, "/asthma_broad_condition.json"))
asthma_json_codelist <- tidyOhdsiRecipies::listConceptIdsFromCs(asthma_json_codes, 
                                                                con, 
                                                                vocabularyDatabaseSchema = executionSettings$cdmDatabaseSchema)

## 2. Searching using regular expression for concepts 
asthma_regex_codes <- tidyOhdsiRecipies::collectCandidatesToCapr(
  con,
  vocabularyDatabaseSchema = executionSettings$cdmDatabaseSchema, 
  c("asthma")
)
asthma_regex_codelist <-  tidyOhdsiRecipies::listConceptIdsFromCs(asthma_regex_codes, 
                                                                  con, 
                                                                  vocabularyDatabaseSchema = executionSettings$cdmDatabaseSchema)

## 3. Using athena codes- https://athena.ohdsi.org/search-terms/terms/317009
asthma_athena_codes <- cs(descendants(317009), name = "asthma")
asthma_athena_codelist <- listConceptIdsFromCs(asthma_athena_codes, con, 
                                               vocabularyDatabaseSchema = executionSettings$cdmDatabaseSchema)


### creating cohort using capR

#caprConceptSets <- collectCaprCsFromCohort(returnTestDonorCohort())

conceptSets <- list(asthma_json_codes, asthma_regex_codes, asthma_athena_codes) ### doesnt work was attempting to make multiple asthma cohorts using the different code list methods
asthma_cohorts <- purrr::map(
  conceptSets,
  ~ createCaprConceptSetCohort(
    conceptSet = .x,
    limit = "all",
    requiredObservation = c(1, 1),
    end = "fixed_exit",
    endArgs = list(
      index = c("startDate"),
      offsetDays = 1
    ),
    addSourceCriteria = TRUE
  )
)

cohortsToCreate <- createCohortDefinitionSet(
  cohorts = asthma_cohorts
)
