## Libs
library(tidyverse)
library(DatabaseConnector)
#remotes::install_github('odyosg/tidyohdsirecipies',force = T)
library(tidyohdsirecipies)
library(FeatureExtraction)
library(dplyr)

################################################################################
# Create results directory ----
resultsFolder <- stringr::str_glue(here("results/HADES/{databaseName}"))

if(!dir.exists(resultsFolder)) {
  dir.create(resultsFolder, recursive = TRUE)
}

################################################################################
# Create logger
logFolder <- stringr::str_glue(here("results/HADES/{databaseName}/log"))
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
source(here("R/HADES/0_CohortGeneration.R"))
info(logger, "Cohort Generation is Complete")
cli::cli_alert(paste0("Cohort Generation is Complete", Sys.time()))

# Analysis 2- Feature Extraction ----
info(logger, "Starting 1_FeatureExtraction.R")
cli::cli_alert(paste0("Running  incidence analysis - ", Sys.time()))
source(here("R/HADES/1_FeatureExtraction.R"))
info(logger, " incidence analysis is Complete")
cli::cli_alert(paste0(" incidence analysis is Complete ", Sys.time()))


output_zip <- file.path(here("results/HADES/study-results"), paste0("study-results-", databaseName, ".zip"))
zip::zipr(zipfile = output_zip, files = list.files(resultsFolder, pattern = databaseName, full.names = T))
cli::cli_alert(paste0("Results saved to ", here("results/HADES/study-results")))


cli::cli_alert("Done!")
cli::cli_alert("-- If all has worked, there should now be a zip folder with your results in the results/study-results directory")