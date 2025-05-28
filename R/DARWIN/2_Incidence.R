#--------------------------------------------
# Incidence analysis ------------------------
#--------------------------------------------
info(logger, "Calculating incidence - {Sys.time()}")
cli::cli_alert("Calculating incidence - {Sys.time()}")

### 3. Generate denominator cohorts --------------------
info(logger, "Generating denominator cohort - {Sys.time()}")
cli::cli_alert("Generating denominator cohort - {Sys.time()}")

# creating a denomination cohort for incidence calculation 
cdm <- IncidencePrevalence::generateDenominatorCohortSet(
  cdm = cdm,
  name = "denominator",
  ageGroup = list(c(0, 120),c(0, 17),c(18,24), c(25,34), c(35,54),c(55,64),c(65,120)),
  sex = c("Male", "Female", "Both"),
  #cohortDateRange = c(as.Date("2019-01-01"), as.Date("2023-12-31")),
  #daysPriorObservation = 0, 
  requirementInteractions = T
)

# getting the labels for denominator groups created for formatting 
denominator_names <- settings(cdm$denominator)

### 1. Generate incidence rates ----------------------------
inc <- estimateIncidence(
  cdm = cdm,
  denominatorTable = "denominator",
  outcomeTable = "targets",
  interval = "years",
  repeatedEvents = TRUE,
  outcomeWashout = 0,
  completeDatabaseIntervals = TRUE
)


### 2. Formatting incidence rates -------------------------
info(logger, "Formatting incidence - {Sys.time()}")
cli::cli_alert("Formatting incidence - {Sys.time()}")

# Table of attrition
tableIncidenceAttrition(inc)

# Censoring incidence rates 
incCensored <- inc |>
  omopgenerics::suppress(minCellCount = minCellCount)

# Plotting incidence
incCensored |> 
  filter(str_detect(pattern = "cohort_2735|cohort_2777",negate = T,group_level)) |>
  plotIncidence(facet = c("denominator_age_group", "denominator_sex"), colour = "outcome_cohort_name")

incCensored |> 
  plotIncidence(facet_wrap(vars(denominator_age_group), ncol = 1))

plotIncidence(incCensored) + 
  facet_wrap(vars(denominator_age_group), ncol = 1)

# Table of incidence 
tableIncidence(incCensored)
