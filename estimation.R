# =============================================================================.
# Estimate Option Implied Probability of Default
# =============================================================================.
# This script estimates the option implied probability of default according to
# Vilsmeier 2014. Depending on the number of option chains provided to the
# algorithm, be prepared for long running times.
# =============================================================================.

# Initialization ----
# -----------------------------------------------------------------------------.
start_time <- Sys.time()

# database
database <- "data/polygonDB.rsqlite"
tableIn  <- "dataset" # name of table including relevant dataset
tableOut <- "results" # name of table on which results should be appended to

# ticker of underlying equities
tickers <- c("CS")

# model parameters
multip <- 30 # multiplication factor for obtaining Vmax

# package management ----
# -----------------------------------------------------------------------------.
library(devtools); load_all()
library(DBI)
library(jsonlite)
library(data.table)



# =============================================================================.
# 1. Estimate PoD ----
# =============================================================================.

# -----------------------------------------------------------------------------.
# 1.1 Prepare data ----
# -----------------------------------------------------------------------------.
cat("\nLoad and prepare data...")

tickers <- paste0("'", paste(tickers, collapse="', '"), "'")
sqlquery <- paste0("SELECT * FROM", tableIn,  "WHERE underlying_ticker IN (", tickers, ")")

# database query for metadata (tickers) and data (options)
db <- dbConnect(RSQLite::SQLite(), database)
dt <- as.data.table(dbGetQuery(db, sqlquery))
dbDisconnect(db)

# parse date
dt <- dt[, date := as.Date(date, origin="1970-01-01")]
dt <- dt[, expiration_date := as.Date(expiration_date, origin="1970-01-01")]

# if risk free interest rate is not available for most recent obervations,
# assume constant interest rate since last observation
if(ticker == "FRCB"){
  dt <- dt[, RF:=0.018]
}
rf <- unique(dt[date == max(dt[!is.na(dt$RF)]$date),]$RF)
dt <- dt[is.na(RF), RF := rf]

# IMPORTANT: order dt according to stike price such that algorithm works
dt <- dt[order(dt$id, dt$strike_price), ]

# only look at 2022 onwards (because of computational time limitations)
dt <- dt[date >= as.Date("2022-01-01"),]

# connect to database
db <- dbConnect(RSQLite::SQLite(), database)
counter <- 1

# for this two option chains algorithm failed
# delete if dataset/ids change
dt <- dt[!(id %in% c(163872, 163934))]

# -----------------------------------------------------------------------------.
# 1.2 estimate PoD ----
# -----------------------------------------------------------------------------.
rm(list = ls()); gc()
for(i in unique(dt$id)){

  cat("\nLoop", counter, "of", length(unique(dt$id)))
  counter <- counter+1

  # get relevant options chain
  temp <- dt[id == i]

  # set model parameters
  mu <- temp$price
  K <- temp$strike_price
  r <- unique(temp$RF)
  ttm <- unique(temp$time_to_maturity)/365
  Lweights <- temp$weight

  # run PoD function
  res <- optipod(mu=mu,K=K,r=r,ttm=ttm,Lweights=Lweights, multiplicationFactor=multip)

  # add some information
  res <- as.data.table(res)
  res <- res[, `:=` (underlying_ticker = unique(temp$underlying_ticker),
                     date = unique(temp$date))]

  # append to database
  dbWriteTable(db, name=tableOut, value=res, row.names=FALSE, append=TRUE)
}
dbDisconnect(db)
cat("\nRuntime:")
Sys.time() - start_time

