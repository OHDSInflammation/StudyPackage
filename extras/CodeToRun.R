### Restore the project library if not the primary author
#renv::activate()
#renv::restore()


#_____________________________________________________________________________
# Connection details - option 1 (single database)

databaseName <- ''
database <- ''
warehouse <- ''
cdmSchema <- c("", "")   # Always hard code schema
writeSchema <- c("", "")
writePrefix <- "" # Initials and project reference to prefix write table; mut be lower case
minCellCount <- 5


conn <- DBI::dbConnect(odbc::odbc(),
                       Driver = "",
                       server = "",
                       port = 443,
                       Role = "",
                       Database = database,
                       Warehouse = warehouse,
                       Uid = Sys.getenv(""),
                       Authenticator = "",
                       PRIV_KEY_FILE = "")


cdm <- CDMConnector::cdmFromCon(con = conn,
                                cdmSchema = cdmSchema,
                                writeSchema = writeSchema,
                                writePrefix = writePrefix)



# Run Analysis ----
source("R/RunAnalysis.R")


