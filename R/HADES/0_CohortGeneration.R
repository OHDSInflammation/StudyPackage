# ============================================================
# Cohort generation
# ============================================================

# define path to cohorts
path_ <- fs::path('target')

target_cohort_dir <- here::here("inst", "targets", "cohorts")

# define generation set
generationSet <- tidyOhdsiRecipies::createCohortDefinitionSet(target_cohort_dir)

## generate cohort set 
generationSet <- CohortGenerator::createEmptyCohortDefinitionSet()
cohortJsonFiles <- list.files(target_cohort_dir)
for (i in 1:length(cohortJsonFiles)) {
  cohortJsonFileName <- file.path(target_cohort_dir, cohortJsonFiles[i])
  cohortName <- tools::file_path_sans_ext(basename(cohortJsonFileName))
  
  ## create cohort sql from cohort json 
  cohortJson <- readChar(cohortJsonFileName, file.info(cohortJsonFileName)$size)
  cohortExpression <- CirceR::cohortExpressionFromJson(cohortJson)
  cohortSql <- CirceR::buildCohortQuery(cohortExpression, options = CirceR::createGenerateOptions(generateStats = FALSE))
  
  ## add cohort sql to cohort generation sey 
  generationSet <- rbind(generationSet, data.frame(cohortId = i,
                                                       cohortName = cohortName, 
                                                       sql = cohortSql,
                                                       stringsAsFactors = FALSE))
}

# run the cohorts from generation set on the writable schema 
CohortGenerator::runCohortGeneration(connectionDetails =  executionSettings$connectionDetails ,
                                     cdmDatabaseSchema =  executionSettings$cdmDatabaseSchema,
                                     tempEmulationSchema = getOption("sqlRenderTempEmulationSchema"),
                                     cohortDatabaseSchema = executionSettings$workDatabaseSchema,
                                     cohortTableNames = CohortGenerator::getCohortTableNames(executionSettings$cohortTable),
                                     cohortDefinitionSet = generationSet,
                                     outputFolder = paste (Database_Name, "_results", sep = ""))


