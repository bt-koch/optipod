# =============================================================================.
# Prepare dataset for estimation process
# =============================================================================.
# Using this script, the dataset which is later used for estimating option
# implied probabilities of default is prepared (with options data from polygon)
# =============================================================================.

# Initialization ----
# -----------------------------------------------------------------------------.
rm(list = ls()); gc()
start_time <- Sys.time()

# database
database <- "data/polygonDB.rsqlite"

# package management ----
# -----------------------------------------------------------------------------.
library(devtools); load_all()
library(DBI)
library(jsonlite)
library(data.table)


# =============================================================================.
# 1. Prepare data set for estimation process ----
# =============================================================================.
cat("\nLoad and prepare data...")

# database query for metadata (tickers) and data (options)
db <- dbConnect(RSQLite::SQLite(), database)
tickers <- as.data.table(dbGetQuery(db, "SELECT * FROM tickers"))
options <- as.data.table(dbGetQuery(db, "SELECT * FROM options"))
dbDisconnect(db)

# merge data with relevant metadata
dt <- merge(
  x = options, y = tickers[, .(ticker, underlying_ticker, expiration_date, strike_price)],
  by = "ticker",
  all.x = TRUE
)

# parse date
dt <- dt[, date := as.POSIXct(t/1000, origin="1970-01-01")]
dt <- dt[, date := as.Date(date)]
dt <- dt[, expiration_date := as.Date(expiration_date)]
dt <- dt[, time_to_maturity := expiration_date-date]

# give each options chain at each measured time point an id
dt <- dt[, id := paste0(substr(ticker, 1, nchar(ticker)-8), date)]
dt <- dt[, id := as.integer(factor(id, levels = unique(id)))]

# calculate weight based on trading volume
dt <- dt[, weight := v/sum(v), by="id"]

# rename column
setnames(dt, "c", "price")

# keep relevant columns
dt <- dt[, .(id, underlying_ticker, date, expiration_date, price, strike_price,
             time_to_maturity, weight)]

rm(options, tickers)


# =============================================================================.
# 2. Stock data ----
# =============================================================================.

db <- dbConnect(RSQLite::SQLite(), database)
stocks <- as.data.table(dbGetQuery(db, "SELECT * FROM stocks"))
dbDisconnect(db)

# parse date
stocks <- stocks[, date := as.POSIXct(t/1000, origin="1970-01-01")]
stocks <- stocks[, date := as.Date(date)]

# create hypothetical option contracts
temp <- copy(dt)
temp <- temp[, `:=` (strike_price = 0, weight = 1, price = 0)]
temp <- unique(temp)
temp <- merge(
  x = temp, y = stocks[, .(ticker, date, c)],
  by.x = c("underlying_ticker", "date"), by.y = c("ticker", "date")
)
temp <- temp[, price := c][, c := NULL]

# only keep observations in dt for which we have stock data
dt <- dt[id %in% unique(temp$id)]

# bind the hypothetical options for current stock price to dt
dt <- rbind(dt, temp)

rm(temp, stocks)


# =============================================================================.
# 3. risk free rate ----
# =============================================================================.

rf <- as.data.table(read.csv("data/F-F_Research_Data_Factors_daily.CSV", skip = 4))
rf$date <- as.Date(rf$X, "%Y%m%d")

dt <- merge(
  x = dt, y = rf[, .(date, RF)],
  by = "date",
  all.x = T
)


# =============================================================================.
# 4. some general adjustments ----
# =============================================================================.

# only keep options with more than one observation
duplicate_id <- duplicated(dt$id) | duplicated(dt$id, fromLast = TRUE)
dt <- dt[duplicate_id,]


# =============================================================================.
# 5. save ----
# =============================================================================.
cat("\nwrite dataset on database:")

db <- dbConnect(RSQLite::SQLite(), database)
if("dataset" %in% dbListTables(db)){
  dbRemoveTable(db, "dataset")
}
dbWriteTable(db, name="dataset", value=dt, row.names=FALSE, append=TRUE)
dbDisconnect(db)

# =============================================================================.
cat("\nRuntime:")
Sys.time() - start_time

