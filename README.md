---
editor_options: 
  markdown: 
    wrap: 72
---

# StudyPackage

Characterizing patients with inflammatory-related conditions

## Introduction

Repository to show an example of how to create and explore inflammation
cohorts using OHDSI community libraries from HADES and DARWIN.

## Cohort Setup

For both DARWIN and HADES packages we need to set up cohorts. This can
be done in several ways:

1.  Create the cohorts in ATLAS and then either manually pull the JSONs
    into the correct directory

    -   Directory location for targets: `inst/targets/cohorts`

    -   Directory location for features: `inst/features/cohorts` (only
        used for the DARWIN packages)

2.  Create the cohorts in ATLAS and then use the R file
    `R/support/Cohort_extraction.R`.

3.  Create cohorts in R using the CapR package which can be done using
    the R file `R/support/CapRCohort.R`.

## HADES

Running the analysis using HADES packages (`CohortGenerator`,
`tidyOhdsiRecipies`, and `FeatureExtraction`).

### Step 0: Cohort JSONs

Check the correct cohort JSON files are located in the
`inst/target/cohorts` folder. If not, add them using the instructions
above for cohort setup.

### Step 1: Code to Run Setup

Ensure the correct connection details for your database are set up in
the file `extras/CodeToRun_HADES.R`.

### Step 2: Execute 'CodeToRun_HADES.R'

Once the connection details have been input run the script
`extras/CodeToRun_HADES.R` this runs the scripts for analysis which can
be found within the folder `R/HADES`. The `R/HADES` folder contains 4
scripts:

-   `0_CohortGeneration.R`: generates the cohorts into your writable
    schema for analysis using `tidyOhdsiRecipies` and `CohortGenerator`.

-   `1_FeatureExtraction.R`: generates the characterization using
    `FeatureExtraction`.

## DARWIN Packages

Running the analysis using DARWIN packages (`CDMConnector`,
`CohortCharacteristics`, `PatientProfiles`, and `IncidencePrevalence`).

### Step 0: Cohort JSONs

Check the correct cohort JSON files are located in the
`inst/target/cohorts` and the `inst/features/cohorts` folders. If not,
add them using the instructions above for cohort setup.

### Step 1: Code to Run Setup

Ensure the correct connection details for your database are set up in
the file `extras/CodeToRun_DARWIN.R`.

### Step 2: Execute 'CodeToRun_DARWIN.R'

Once the connection details have been input run the script
`extras/CodeToRun_DARWIN.R` this runs the scripts for analysis which can
be found within the folder `R/DARWIN`. The `R/DARWIN` folder contains 4
scripts:

-   `0_CohortGeneration.R`: generates the cohorts into your writable
    schema for analysis using CDMConnector.

-   `1_CohortCharacterization.R`: generates the characterization using
    `CohortCharacteristics` and `PatientProfiles`.

-   `2_Incidence.R`: generates the incidence using
    `IncidencePrevalence`.

-   `RunAnalysis.R` : script which executes all the others in order.
