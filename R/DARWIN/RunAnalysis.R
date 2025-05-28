library(CDMConnector)
library(ROhdsiWebApi)
library(dplyr)
library(jsonlite)
library(log4r)
library(cli)
library(odbc)
library(here)
library(CirceR)
library(CohortGenerator)
library(CohortCharacteristics)
library(IncidencePrevalence)
library(ggplot2)
library(omopgenerics)
library(tidyr)
library(openxlsx)
library(stringr)
library(gt)
library(PatientProfiles)

################################################################################
# Create results directory ----
resultsFolder <- stringr::str_glue(here("results/DARWIN/{databaseName}"))

if(!dir.exists(resultsFolder)) {
  dir.create(resultsFolder, recursive = TRUE)
}

################################################################################
# Create logger
logFolder <- stringr::str_glue(here("results/DARWIN/{databaseName}/log"))
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
cli::cli_alert(paste0("Generating Study Cohorts - ", Sys.time()))
source(here("R/DARWIN/0_CohortGeneration.R"))
info(logger, "Cohort Generation is Complete")
cli::cli_alert(paste0("Cohort Generation is Complete", Sys.time()))

# Analysis 1- Characterization ---- 
info(logger, "Starting 1_Characterization.R")
cli::cli_alert(paste0("Running Characterization - ", Sys.time()))
source(here("R/DARWIN/1_Characterization.R"))
info(logger, "Characterization is Complete")
cli::cli_alert(paste0("Characterization is Complete ", Sys.time()))

# Analysis 2- Incidence Prevalence ----
info(logger, "Starting 2_Incidence.R")
cli::cli_alert(paste0("Running  incidence analysis - ", Sys.time()))
source(here("R/DARWIN/2_Incidence.R"))
info(logger, " incidence analysis is Complete")
cli::cli_alert(paste0(" incidence analysis is Complete ", Sys.time()))


output_zip <- file.path(here("results/DARWIN/study-results"), paste0("study-results-", databaseName, ".zip"))
zip::zipr(zipfile = output_zip, files = list.files(resultsFolder, pattern = databaseName, full.names = T))
cli::cli_alert(paste0("Results saved to ", here("results/DARWIN/study-results")))


cli::cli_alert("Done!")
cli::cli_alert("-- If all has worked, there should now be a zip folder with your results in the results/study-results directory")