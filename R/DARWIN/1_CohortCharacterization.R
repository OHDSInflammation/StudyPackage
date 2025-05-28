# ============================================================
# Characterization Script
# ============================================================

# ------------------------------------------------------------
# 1. Basic Demographics using PatientProfiles
# ------------------------------------------------------------

# Add age (with groups), sex, and prior observation period to the target cohort
cdm$targets <- cdm$targets |>
  addAge(
    indexDate = "cohort_start_date", 
    ageGroup = list(c(0, 18), c(19, 65), c(66, 100))
  ) |>
  addSex() |>
  addPriorObservation()

# Summarize age and sex characteristics
ageSex <- cdm$targets |>
  summariseResult(
    strata = list("cohort_definition_id"),
    variables = list("age", c("age_group", "sex")),
    estimates = list(c("mean", "sd"), c("count", "percentage")),
    counts = TRUE
  ) |>
  select(strata_name, strata_level, variable_name, estimate_name, estimate_value) |>
  omopgenerics::suppress(minCellCount = minCellCount)

# ------------------------------------------------------------
# 2. Ethnicity and Race (via dplyr joins)
# ------------------------------------------------------------

# Ethnicity breakdown
ethnicty <- cdm$targets |> 
  left_join(cdm$person, by = join_by("subject_id" == "person_id")) |>
  left_join(cdm$concept, by = c("ethnicity_concept_id" = "concept_id")) |>
  group_by(cohort_definition_id, concept_name) |>
  summarise(count = n_distinct(subject_id)) |>
  rename(ethnicity = concept_name) |>
  collect()

# Race breakdown
race <- cdm$targets |> 
  left_join(cdm$person, by = join_by("subject_id" == "person_id")) |>
  left_join(cdm$concept, by = c("race_concept_id" = "concept_id")) |>
  group_by(cohort_definition_id, concept_name) |>
  summarise(count = n_distinct(subject_id)) |>
  rename(race = concept_name) |>
  collect()

# ------------------------------------------------------------
# 3. Clinical Characteristics using CohortCharacteristics
# ------------------------------------------------------------

# Top 10 comorbidities in the past year
comorbidities <- cdm$targets |>
  CohortCharacteristics::summariseLargeScaleCharacteristics(
    window = list("365daysprior" = c(-365, 0), "alltimeprior" = c(-Inf,0)),
    eventInWindow = "condition_occurrence",
    minimumFrequency = 0.005
  ) |>
  omopgenerics::suppress(minCellCount = minCellCount)

# Top 10 drugs in the past year
drugs <- cdm$targets |>
  CohortCharacteristics::summariseLargeScaleCharacteristics(
    window = list("365daysprior" = c(-365, 0), "alltimeprior" = c(-Inf,0)),
    eventInWindow = "drug_exposure",
    minimumFrequency = 0.005
  ) |>
  omopgenerics::suppress(minCellCount = minCellCount)

# ------------------------------------------------------------
# 4. Specific Measurement: BMI
# ------------------------------------------------------------

# Identify BMI-related concept IDs
bmi_codes <- cdm$concept |> 
  left_join(cdm$concept_ancestor, by = join_by("concept_id" == "descendant_concept_id")) |>
  filter(ancestor_concept_id %in% c(44783982, 3038553)) |> 
  pull(concept_id)

# Add BMI measurement field to the cohort
cdm$targets <- cdm$targets |>
  addConceptIntersectField(
    conceptSet = list("bmi" = bmi_codes),
    field = "value_as_number", 
    window = c(-365, 0), 
    order = "last",
    allowDuplicates = TRUE
  )

# Summarize BMI values
bmi <- cdm$targets |>
  summariseResult(
    strata = list("cohort_definition_id"),
    variables = list("value_as_number_bmi_m365_to_0"),
    estimates = list(c("mean", "sd")),
    counts = TRUE
  ) |>
  select(strata_name, strata_level, variable_name, estimate_name, estimate_value)


# ------------------------------------------------------------
# 5. Formatting characterisation
# ------------------------------------------------------------

