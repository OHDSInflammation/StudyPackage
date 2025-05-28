# ============================================================
# Feature Extraction
# ============================================================

# ------------------------------------------------------------
# 1. Cohort counts
# ------------------------------------------------------------
cohortCounts <- CohortGenerator::getCohortCounts(connectionDetails =  executionSettings$connectionDetails,
                                 cohortDatabaseSchema = executionSettings$workDatabaseSchema,
                                 cohortTable = executionSettings$cohortTable)


# ------------------------------------------------------------
# 2. Covariate set up 
# ------------------------------------------------------------

# demographics (age, sex, ethnicity and race), conditions and treatment
covSet_general <- FeatureExtraction::createCovariateSettings(
  # demographics (age, sex, ethnicity and race)
  useDemographicsGender = TRUE,
  useDemographicsAge = TRUE,
  useDemographicsRace = TRUE,
  useDemographicsEthnicity = TRUE,
  # conditions 
  useConditionEraAnyTimePrior = TRUE,
  useConditionEraLongTerm = TRUE, 
  # medications
  useDrugEraAnyTimePrior = TRUE,
  useDrugEraLongTerm = TRUE, 
  longTermStartDays = -365
)

# bmi 
covSet_bmi <- FeatureExtraction::createCovariateSettings(
  useMeasurementLongTerm = TRUE,
  longTermStartDays = -365,
  endDays = 0,
  includedCovariateConceptIds = c(
    # BMI codes (measurement domain)
    44783982, 3038553
  )
)




# ------------------------------------------------------------
# 3. Covariate generation - aggregated results
# ------------------------------------------------------------
cohortIdsVector <- generationSet |> pull(cohortId)

## Generate the aggregated results for the covariates selected above

# Iterate over each cohort ID, extract the covariate data, and add a marker for each cohort
resultList <- lapply(cohortIdsVector, function(cohortId) {

  # Extract the covariate data for the current cohort id
  covDataObject <-FeatureExtraction::getDbCovariateData(
    connectionDetails = executionSettings$connectionDetails, # database connection details
    cdmDatabaseSchema = executionSettings$cdmDatabaseSchema, # The database you're connecting to
    cohortTable = executionSettings$cohortTable, # Within the database, the cohort table
    cohortDatabaseSchema = executionSettings$workDatabaseSchema, # Your writable schema
    cohortIds = cohortId,
    covariateSettings = covSet_general,  # The covariates you specified earlier
    aggregated = TRUE # aggregate the data 
  )

  # join the aggregated data and reference covariate id
  covDataAgg <- as.data.frame(covDataObject$covariates) 
  covRefAgg <- as.data.frame(covDataObject$covariateRef)
  covAggJoin <- covDataAgg |>
    left_join(covRefAgg |> select(covariateId,covariateName), by = "covariateId") 
  
  covAggJoin$cohortId <- cohortId
  
  # Return a list containing all data frames
  return(covAggJoin)
})

# Combine all the individual data frames across cohorts:
covariatesGeneral <- do.call(rbind, resultList)


# ------------------------------------------------------------
# 4. Covariate generation - non-aggregated bmi results
# ------------------------------------------------------------

## Generate the non aggregated results for the BMI covariate 

# Iterate over each cohort ID, extract the covariate data, and add a marker for each cohort
resultList_bmi <- lapply(cohortIdsVector, function(cohortId) {
  
  # Extract the covariate data for the current cohort id
  covDataObject <-FeatureExtraction::getDbCovariateData(
    connectionDetails = executionSettings$connectionDetails, # database connection details
    cdmDatabaseSchema = executionSettings$cdmDatabaseSchema, # The database you're connecting to
    cohortTable = executionSettings$cohortTable, # Within the database, the cohort table
    cohortDatabaseSchema = executionSettings$workDatabaseSchema, # Your writable schema
    cohortIds = cohortId,
    covariateSettings = covSet_bmi  # The covariates you specified earlier
  )
  
  # Convert the covariates component to a data frame and tag it with the current cohort ID
  covData <- as.data.frame(covDataObject$covariates)
  covData$cohortId <- cohortId
  
  # Convert the covariate reference component to a data frame and tag it as well
  covRef <- as.data.frame(covDataObject$covariateRef)
  covRef$cohortId <- cohortId
  
  # join data and reference covariate id
  covJoin <- covData |>
    left_join(covRef |> select(covariateId,covariateName), by = "covariateId") 
  
  # Return a list containing all data frames
  return(covJoin)
  

})

# Combine all the individual data frames across cohorts:
covariatesBmi <- do.call(rbind, resultList_bmi) |> 
  filter(covariateValue != 0) |> 
  group_by(cohortId) |> 
  summarise(covariateValue = mean(covariateValue))



