rm(list=ls()); gc()
library(devtools); load_all()
library(jsonlite)

apikey <- readLines("data/apikey.txt")

writeToFile <- function(text) {
  file <- "data/tickers.txt"  # Replace with the actual file path

  # Open the file in append mode and write the content
  con <- file(file, "a")
  writeLines(text, con)
  close(con)
}

# search ticker for JPMorgan Chase
test <- extractPolygonTickers(apikey, "JPMorgan")
writeToFile("JPM")

# search ticker for Bank of America
test <- extractPolygonTickers(apikey, "BAC")
writeToFile("BAC")

# search ticker for Citigroup
test <- extractPolygonTickers(apikey, "Citigroup")
writeToFile("C")

# search ticker for Wells Fargo
test <- extractPolygonTickers(apikey, "Wells")
writeToFile("WFC")

# search ticker for Goldman Sachs
test <- extractPolygonTickers(apikey, "Goldman")
writeToFile("GS")

