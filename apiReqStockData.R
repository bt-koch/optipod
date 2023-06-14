# =============================================================================.
# Get Stock Data via polygon.io API
# =============================================================================.
# Using this script, stock data for all tickers contained in database is
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
# 1. Get Stock Data via polygon.io API ----
# =============================================================================.
cat("\nLoad and prepare data...")

# get tickers for all stocks
tickers <- readRDS("data/tickers.rds")
tickers <- tickers$ticker

# unfortunately, I cannot estimate the PoD for all banks I wanted due to
# computational limitations, so I reduce the sample
tickers <- c()

# the 3 biggest banks in the US
tickers <- c(tickers, "JPM", "BAC", "C")

# banks comparable to SVB and First Republic Bank (in terms of total assets)
tickers <- c(tickers, "CFG", "HSBC", "SIVBQ", "FRCB", "FITB")

# the Swiss banks
tickers <- c(tickers, "UBS", "CS")

# banks comparable to CS (in terms of total assets)
tickers <- c(tickers, "VLY", "MFG", "WTFC")

# since we query all stocks, clear relevant table if already exists
db <- dbConnect(RSQLite::SQLite(), database)
if("stocks" %in% dbListTables(db)){
  dbRemoveTable(db, "stocks")
}
dbDisconnect(db)

# get all option data
extractPolygonStocks(apikey = apikey,
                     tickers = tickers,
                     database = database,
                     from = "2019-06-10",
                     to = "2023-06-02",
                     limitedAPIcalls = T)

# =============================================================================.
cat("\nRuntime:")
Sys.time() - start_time

