# =============================================================================.
# Get Options Data via polygon.io API
# =============================================================================.
# Using this script, options data for all tickers contained in database is
# requested from polygon.io API
# =============================================================================.

# Initialization ----
# -----------------------------------------------------------------------------.
rm(list = ls()); gc()
start_time <- Sys.time()

# database
database <- "data/polygonDB.rsqlite"
# API key
apikey <- readLines("data/apikey.txt")

# package management ----
# -----------------------------------------------------------------------------.
library(devtools); load_all()
library(DBI)
library(jsonlite)

# =============================================================================.
# 1. Get Options Data via polygon.io API ----
# =============================================================================.
cat("\nLoad and prepare data...")

# get tickers for all options
db <- dbConnect(RSQLite::SQLite(), database)
tickers <- dbGetQuery(db, "SELECT * FROM tickers")
tickers <- tickers$ticker
dbDisconnect(db)

# since we query all option tickers, clear relevant table if already exists
# db <- dbConnect(RSQLite::SQLite(), database)
# if("options" %in% dbListTables(db)){
#   dbRemoveTable(db, "options")
# }
# dbDisconnect(db)

# get all option data
extractPolygonOptContracts(apikey = apikey,
                           tickers = tickers,
                           from = "2019-01-07",
                           to = "2023-06-07",
                           database = database,
                           adjusted="true",
                           limit=50000,
                           limitedAPIcalls=F)


cat("\nRuntime:")
Sys.time() - start_time

