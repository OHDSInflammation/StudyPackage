## generate cohorts using Capr
#remotes::install_github("ohdsi/Capr")
library(Capr)

##  read code lists from JSONs 
codelist_dir <- here::here("inst", "codeLists")
asthma <- Capr::readConceptSet(path = paste0(codelist_dir, "/asthma_broad_condition.json"))
inhaled_beta2 <- Capr::readConceptSet(path = paste0(codelist_dir, "/beta2agonist_inhaled.json"))
oral_steroids <- Capr::readConceptSet(path = paste0(codelist_dir, "/steriod_oral.json"))

## loop through the different severity levels and pre and post covid 
ch_entry = entry(
  conditionOccurrence(asthma_json_codes,condStart = c("2024-01-01", "2024-01-01")),
  #startDate("2024-01-01"),
  observationWindow = continuousObservation(180,1), 
  primaryCriteriaLimit = "First",
  qualifiedLimit = "First"
)

ch <- cohort(
  entry = entry(
    conditionOccurrence(asthma_json_codes,condStart = "2024-01-01"),
    #startDate("2024-01-01"),
    observationWindow = continuousObservation(180,1), 
    primaryCriteriaLimit = "First",
    qualifiedLimit = "First"
  ),
  ## attrition criteria leidy
  attrition(
    "leidySevere" = withAny(
      # with at most 1 inhaled beta-2 and at least 3 oral steriods
      withAll(
        atMost(
          x = 1,
          aperture = duringInterval(eventStarts(-548, 0)),
          query = drugExposure(conceptSet = inhaled_beta2)
        ),
        atLeast(
          x = 3,
          aperture = duringInterval(eventStarts(-548, 0)),
          query = drugExposure(conceptSet = oral_steroids)
        )
      ),
      # with at most 2 inhaled beta-2 and at least 3 oral steriods
      withAll(
        atMost(
          x = 2,
          aperture = duringInterval(eventStarts(-548, 0)),
          query = drugExposure(conceptSet = inhaled_beta2)
        ),
        atLeast(
          x = 3,
          aperture = duringInterval(eventStarts(-548, 0)),
          query = drugExposure(conceptSet = oral_steroids)
        )
      ),
      # with at most 3 inhaled beta-2 and at least 3 oral steriods
      withAll(
        atMost(
          x = 3,
          aperture = duringInterval(eventStarts(-548, 0)),
          query = drugExposure(conceptSet = inhaled_beta2)
        ),
        atLeast(
          x = 3,
          aperture = duringInterval(eventStarts(-548, 0)),
          query = drugExposure(conceptSet = oral_steroids)
        )
      ),
      # with at most 4 inhaled beta-2 and at least 3 oral steriods
      withAll(
        atMost(
          x = 4,
          aperture = duringInterval(eventStarts(-548, 0)),
          query = drugExposure(conceptSet = inhaled_beta2)
        ),
        atLeast(
          x = 3,
          aperture = duringInterval(eventStarts(-548, 0)),
          query = drugExposure(conceptSet = oral_steroids)
        )
      ),
      # with at most 5 inhaled beta-2 and at least 3 oral steriods
      withAll(
        atMost(
          x = 5,
          aperture = duringInterval(eventStarts(-548, 0)),
          query = drugExposure(conceptSet = inhaled_beta2)
        ),
        atLeast(
          x = 3,
          aperture = duringInterval(eventStarts(-548, 0)),
          query = drugExposure(conceptSet = oral_steroids)
        )
      ),
      # with at most 6 inhaled beta-2 and at least 3 oral steriods
      withAll(
        atMost(
          x = 6,
          aperture = duringInterval(eventStarts(-548, 0)),
          query = drugExposure(conceptSet = inhaled_beta2)
        ),
        atLeast(
          x = 3,
          aperture = duringInterval(eventStarts(-548, 0)),
          query = drugExposure(conceptSet = oral_steroids)
        )
      ),
      # with at most 7 inhaled beta-2 and at least 2 oral steriods
      withAll(
        atMost(
          x = 7,
          aperture = duringInterval(eventStarts(-548, 0)),
          query = drugExposure(conceptSet = inhaled_beta2)
        ),
        atLeast(
          x = 2,
          aperture = duringInterval(eventStarts(-548, 0)),
          query = drugExposure(conceptSet = oral_steroids)
        )
      )
    )
  ),
  exit = exit(
    endStrategy = observationExit()
  )
)

cohortJson <- compile(ch)
writeLines(cohortJson, con = "cohort_definition.json")


