rm(list=ls()); gc()
library(jsonlite)
library(DBI)
library(devtools); load_all()

apikey <- readLines("data/apikey.txt")

tickers <- c()

temp <- extractPolygonOptTickers(
  apikey = apikey,
  limit = 1000,
  ticker = "CS",
  expiration_date.gte = "2022-01-01"
)

tickers <- c(tickers, temp$ticker)

temp <- extractPolygonOptTickers(
  apikey = apikey,
  limit = 1000,
  ticker = "UBS",
  expiration_date.gte = "2022-01-01"
)

tickers <- c(tickers, temp$ticker)

# -----

extractPolygonOptContracts(
  apikey = apikey,
  tickers = tickers,
  from = "2021-06-03",
  to = "2023-06-03",
  database = "data/polygonDB.rsqlite"
)
