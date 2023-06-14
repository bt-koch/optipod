# =============================================================================.
# Prepare dataset for estimation process
# =============================================================================.
# Using this script, the dataset which is later used for estimating option
# implied probabilities of default is prepared (with options data from WRDS)
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

dt <- as.data.table(read.csv("data/cs-wrds.csv"))

# add ticker
dt$underlying_ticker <- "CS"

# only keep call options
dt <- dt[dt$cp_flag == "C"]

# rename columns
setnames(dt, "exdate", "expiration_date")

# parse date
dt <- dt[, date := as.Date(date, "%Y-%m-%d")]
dt <- dt[, expiration_date := as.Date(expiration_date, "%Y-%m-%d")]
dt <- dt[, time_to_maturity := expiration_date-date]

# calculate price
dt$price <- rowMeans(dt[, c("best_bid", "best_offer")])

# change unit of strike price
dt <- dt[, strike_price := strike_price/1000]

# give each options chain at each measured time point an id
dt <- dt[, id := paste0(date, expiration_date)]
dt <- dt[, id := as.integer(factor(id, levels = unique(id)))]

# calculate weight based on trading volume
dt <- dt[volume > 0]
dt <- dt[, weight := volume/sum(volume), by="id"]

# keep relevant columns
dt <- dt[, .(id, underlying_ticker, date, expiration_date, price, strike_price,
             time_to_maturity, weight)]


# =============================================================================.
# 2. Stock ----
# =============================================================================.

stocks <- as.data.table(read.csv("data/cs-yahoo.csv"))

# parse date
stocks <- stocks[, date := as.Date(Date, "%Y-%m-%d")]


# create hypothetical option contracts
temp <- copy(dt)
temp <- temp[, `:=` (strike_price = 0, weight = 1, price = 0)]
temp <- unique(temp)
temp <- merge(
  x = temp, y = stocks[, .(date, Close)],
  by = "date"
)
temp <- temp[, price := Close][, Close := NULL]

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
if("dataset_WRDS" %in% dbListTables(db)){
  dbRemoveTable(db, "dataset_WRDS")
}
dbWriteTable(db, name="dataset_WRDS", value=dt, row.names=FALSE, append=TRUE)
dbDisconnect(db)

# =============================================================================.
cat("\nRuntime:")
Sys.time() - start_time

