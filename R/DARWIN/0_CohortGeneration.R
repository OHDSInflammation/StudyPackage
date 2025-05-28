# ============================================================
# Cohort generation
# ============================================================

# ------------------------------------------------------------
# 1. Import Cohort Definition JSON files
# ------------------------------------------------------------
cli::cli_alert("Importing Cohort Definitions")

# target and feature cohorts directories
target_cohort_dir <- here::here("inst", "targets", "cohorts")
feature_cohort_dir <- here::here("inst", "features", "cohorts")

# ------------------------------------------------------------
# 2. Generate target and feature cohorts
# ------------------------------------------------------------
## target cohorts
cli::cli_alert("Generating target cohorts - {Sys.time()}")

# read in cohort set from directory 
target_cohorts <- CDMConnector::readCohortSet(target_cohort_dir)

# generate the cohort set in the cdm object
cdm <- CDMConnector::generateCohortSet(cdm, target_cohorts, name = "targets")

## feature cohorts
cli::cli_alert("Generating feature cohorts - {Sys.time()}")

# read in cohort set from directory 
feature_cohorts <- CDMConnector::readCohortSet(feature_cohort_dir)

# generate the cohort set in the cdm object
cdm <- CDMConnector::generateCohortSet(cdm, feature_cohorts, name = "features")