# =============================================================================.
# Get Option Tickers via polygon.io API
# =============================================================================.
# Using this script, option tickers for all underlyings is requested from
# polygon.io API
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
# 1. Get option tickers via API Requests ----
# =============================================================================.
cat("\nAPI request...")

# get tickers for all underlying stocks we want options data
tickers <- readRDS("data/tickers.rds")
tickers <- tickers$ticker

# create time frames for which we make API request to avoid reaching limit
years <- c("2020", "2021", "2022", "2023")
dateStart <- c("-01-01", "-02-01", "-03-01", "-04-01", "-05-01", "-06-01",
               "-07-01", "-08-01", "-09-01", "-10-01", "-11-01", "-12-01")
dateEnd <- c("-01-31", "-02-28", "-03-31", "-04-30", "-05-31", "-06-30",
             "-07-31", "-08-31", "-09-30", "-10-31", "-11-30", "-12-31")

dateStart <- expand.grid(years, dateStart)
dateStart <- data.frame(
  startdate = paste0(dateStart$Var1, dateStart$Var2)
)
dateStart$id <- substr(dateStart$startdate, 1, 7)

dateEnd <- expand.grid(years, dateEnd)
dateEnd <- data.frame(
  enddate = paste0(dateEnd$Var1, dateEnd$Var2)
)
dateEnd$id = substr(dateEnd$enddate, 1, 7)

dates <- merge(
  x = dateStart, y = dateEnd,
  by = "id",
  all = T
)
rm(years, dateStart, dateEnd)

# since we query all option tickers, clear relevant table if already exists
db <- dbConnect(RSQLite::SQLite(), database)
if("tickers" %in% dbListTables(db)){
  dbRemoveTable(db, "tickers")
}
dbDisconnect(db)

# get all option tickers per month
for(i in 1:nrow(dates)){
  cat("\nAPI requests for month", dates[i,]$id)

  extractPolygonOptTickers(apikey, tickers = tickers, limitedAPIcalls = F,
                           expiration_date.gte = dates[i,]$startdate,
                           expiration_date.lte = dates[i,]$enddate,
                           database="data/polygonDB.rsqlite")

}

# =============================================================================.
cat("\nRuntime:")
Sys.time() - start_time

