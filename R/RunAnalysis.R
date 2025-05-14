################################################################################

# Tidy up packages
#### Load packages
library(CDMConnector)
library(tidyverse)
library(CDMConnector)
library(here)
library(log4r)

library(bslib)
library(checkmate)
library(CirceR)
library(cli)
library(CodelistGenerator)
library(CohortCharacteristics)
library(CohortDiagnostics)
library(CohortGenerator)
library(CohortSurvival)
library(dbplyr)
library(dplyr)
library(DrugExposureDiagnostics)
library(DrugUtilisation)
library(DT)
library(FeatureExtraction)
library(fs)
library(ggplot2)
library(glue)
library(gridExtra)
library(gt)
library(here)
library(IncidencePrevalence)
library(jsonlite)
library(kableExtra)
library(log4r)
library(odbc)
library(omopgenerics)
library(PatientProfiles)
library(plotly)
library(purrr)
library(readr)
library(readxl)
library(remotes)
library(ROhdsiWebApi)
library(shiny)
library(shinycssloaders)
library(shinyjs)
library(shinyWidgets)
library(SqlRender)
library(stringr)
library(tidyr)
library(tools)
library(utils, lib.loc = .Library)
library(writexl)
library(yaml)
library(zip)
#


################################################################################
# Create results directory ----
resultsFolder <- stringr::str_glue(here("results/{databaseName}"))

if(!dir.exists(resultsFolder)) {
  dir.create(resultsFolder, recursive = TRUE)
}

################################################################################
# Create logger
logFolder <- stringr::str_glue(here("results/{databaseName}/log"))
log_file <- here(logFolder, "log.txt")
if(!dir.exists(logFolder)) {
  dir.create(logFolder, recursive = TRUE)
}

logger <- log4r::create.logger()
logfile(logger) <- log_file
level(logger) <- "INFO"

################################################################################
# Run Analysis scripts
# Generate Study Cohorts -----
info(logger, "Starting 0_CohortGeneration.R")
print(paste0("Generating Study Cohorts - ", Sys.time()))
source(here("R/0_CohortGeneration.R"))
info(logger, "Cohort Generation is Complete")
print(paste0("Cohort Generation is Complete", Sys.time()))


# Analysis 1- Incidence Prevalence ----
info(logger, "Starting 1_IncidencePrevalence.R")
print(paste0("Running  incidence/prevalence analysis - ", Sys.time()))
source(here("R/1_IncidencePrevalence_ingredient.R"))
info(logger, " incidence/prevalence analysis is Complete")
print(paste0(" incidence/prevalence analysis is Complete ", Sys.time()))


# Analysis 2- Characterization ---- # Update
info(logger, "Starting 3_IncidencePrevalence_product.R")
print(paste0("Running  incidence/prevalence analysis @ Product Level - ", Sys.time()))
source(here("R/3_IncidencePrevalence_product.R"))
info(logger, " incidence/prevalence @ Product Level analysis is Complete")
print(paste0(" incidence/prevalence @ Product Level analysis is Complete ", Sys.time()))


output_zip <- file.path(here("results/study-results"), paste0("study-results-", dbName, ".zip"))
zip::zipr(zipfile = output_zip, files = list.files(resultsFolder, pattern = dbName, full.names = T))
print(paste0("Results saved to ", here("results/study-results")))


print("Done!")
print("-- If all has worked, there should now be a zip folder with your results in the results/study-results directory")
print("-- Thank you for running the study!")