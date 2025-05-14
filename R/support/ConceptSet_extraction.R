library(ROhdsiWebApi)
library(omopgenerics)
library(DrugUtilisation)
library(CodelistGenerator)
library(here)
library(jsonlite)
library(tidyverse)


# Connect to ATLAS WebAPI and authenticate
baseUrl <- Sys.getenv("baseUrl")   ## ATLAS address
ROhdsiWebApi::authorizeWebApi(baseUrl = Sys.getenv("baseUrl"),
                              authMethod = "ad",
                              webApiUsername = Sys.getenv('ATLAS_USER'),    ### If needed
                              webApiPassword = Sys.getenv('ATLAS_PASSWORD')) ### If needed


conceptSetId <- c()
category <- ''   # what domain the concept set belongs in

for (i in conceptSetId) {
  
  conceptSet <- getConceptSetDefinition(i, baseUrl)
  name <- str_remove(conceptSet$name)  # str_remove(conceptSet$name, " ")
  conceptSetJson <- toJSON(conceptSet$expression, pretty = T)
  write_json(conceptSet$expression, path = stringr::str_glue('inst/Concept_sets/{category}/{name}.json'), pretty = TRUE)
  
}


codes <- codesFromConceptSet(path = stringr::str_glue('inst/Concept_sets/{category}/{name}.json', cdm, type = c("codelist")))


