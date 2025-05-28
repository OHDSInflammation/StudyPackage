################################################################################
# This template script can be used to extract cohort definitions from ATLAS to
# be used in a study.
################################################################################
# Load librarys
library(ROhdsiWebApi)
library(tidyverse)
library(CohortGenerator)


################################################################################
# Connect to ATLAS WebAPI and authenticate
baseUrl <- Sys.getenv("baseUrl")
ROhdsiWebApi::authorizeWebApi(baseUrl = baseUrl, ## ATLAS url
                              authMethod = "ad",
                              webApiUsername = Sys.getenv('ATLAS_USER'),    ## if needed
                              webApiPassword = Sys.getenv('ATLAS_PASSWORD')) ## if needed



################################################################################
### Extract and save cohort definitions
### Repeat code block per cohort type (e.g. for target, comorbiditiy, outcome etc)

# Inputs

### - Target cohorts 
cohort_type <- 'targets'   ## Cohort type, cohorts will be saved in a directory with this name
cohortIds <- c(2964,
               2963,
               2962,
               2960,
               2959,
               2955) ## Cohort definitions from ATLAS 

## Pull definitions from ATLAS
cohortDefinitionSet <- ROhdsiWebApi::exportCohortDefinitionSet(
  baseUrl = baseUrl,
  cohortIds = cohortIds
)

# Save Cohort definitions
saveCohortDefinitionSet(
  cohortDefinitionSet = cohortDefinitionSet,
  settingsFileName = file.path(
    stringr::str_glue("inst/{cohort_type}/settings/CohortsToCreate.csv")
  ),
  jsonFolder = file.path(
    stringr::str_glue("inst/{cohort_type}/cohorts")
  ),
  sqlFolder = file.path(
    stringr::str_glue("inst/{cohort_type}/sql/sql_server")
  )
)




### - Feature cohorts 
cohort_type <- 'features'   ## Cohort type, cohorts will be saved in a directory with this name
cohortIds <- c(2833,2806) ## Cohort definitions from ATLAS 

## Pull definitions from ATLAS
cohortDefinitionSet <- ROhdsiWebApi::exportCohortDefinitionSet(
  baseUrl = baseUrl,
  cohortIds = cohortIds
)

# Save Cohort definitions
saveCohortDefinitionSet(
  cohortDefinitionSet = cohortDefinitionSet,
  settingsFileName = file.path(
    stringr::str_glue("inst/{cohort_type}/settings/CohortsToCreate.csv")
  ),
  jsonFolder = file.path(
    stringr::str_glue("inst/{cohort_type}/cohorts")
  ),
  sqlFolder = file.path(
    stringr::str_glue("inst/{cohort_type}/sql/sql_server")
  )
)
