rm(list=ls()); gc()
library(devtools); load_all()
library(jsonlite)
library(data.table)

apikey <- readLines("data/apikey.txt")

tickers <- data.table()

saveTicker <- function(text){
  test <- as.data.table(test)
  test <- test[ticker == text]
  tickers <<- rbind(tickers, test, fill=T)
}

# search ticker for JPMorgan Chase
test <- extractPolygonTickers(apikey, "JPMorgan")
saveTicker("JPM")

# search ticker for Bank of America
test <- extractPolygonTickers(apikey, "BAC")
saveTicker("BAC")

# search ticker for Citigroup
test <- extractPolygonTickers(apikey, "Citigroup")
saveTicker("C")

# search ticker for Wells Fargo
test <- extractPolygonTickers(apikey, "Wells")
saveTicker("WFC")

# search ticker for Goldman Sachs
test <- extractPolygonTickers(apikey, "Goldman")
saveTicker("GS")

# search ticker for Morgan Stanley
test <- extractPolygonTickers(apikey, "Stanley")
saveTicker("MS")

# search ticker for U.S. Bancorp
test <- extractPolygonTickers(apikey, "Bancorp")
saveTicker("USB")

# search ticker for PNC Financial Services
test <- extractPolygonTickers(apikey, "PNC")
saveTicker("PNC")

# search ticker for Truist Financial
test <- extractPolygonTickers(apikey, "Truist")
saveTicker("TFC")

# search ticker for Charles Schwab Corporation
test <- extractPolygonTickers(apikey, "Schwab")
saveTicker("SCHW")

# search ticker for TD Bank, N.A.
# test <- extractPolygonTickers(apikey, "TD")
# not found

# search ticker for Capital One
test <- extractPolygonTickers(apikey, "COF")
saveTicker("COF")

# search ticker for The Bank of New York Mellon
test <- extractPolygonTickers(apikey, "Mellon")
saveTicker("BK")

# search ticker for State Street Corporation
test <- extractPolygonTickers(apikey, "Street")
saveTicker("STT")

# search ticker for American Express
test <- extractPolygonTickers(apikey, "Express")
saveTicker("AXP")

# search ticker for Citizens Financial Group
test <- extractPolygonTickers(apikey, "Citizens")
saveTicker("CFG")

# search ticker for HSBC Bank USA
test <- extractPolygonTickers(apikey, "HSBC")
saveTicker("HSBC")

# search ticker for SVB Financial Group
test <- extractPolygonTickers(apikey, "SVB")
saveTicker("SIVBQ")

# search ticker for First Republic Bank
test <- extractPolygonTickers(apikey, "FRCB")
saveTicker("FRCB")

# search ticker for Fifth Third Bank
test <- extractPolygonTickers(apikey, "FITB")
saveTicker("FITB")

# search ticker for Bank of Montreal
test <- extractPolygonTickers(apikey, "BMO")
saveTicker("BMO")

# search ticker for United Services Automobile Association
# test <- extractPolygonTickers(apikey, "USAA")
# not traded publicly

# search ticker for UBS
test <- extractPolygonTickers(apikey, "UBS")
saveTicker("UBS")

# search ticker for M&T Bank
test <- extractPolygonTickers(apikey, "MTB")
saveTicker("MTB")

# search ticker for Ally Financial
test <- extractPolygonTickers(apikey, "Ally")
saveTicker("ALLY")

# search ticker for KeyCorp
test <- extractPolygonTickers(apikey, "KeyCorp")
saveTicker("KEY")

# search ticker for Huntington Bancshares
test <- extractPolygonTickers(apikey, "Huntington")
saveTicker("HBAN")

# search ticker for Barclays
test <- extractPolygonTickers(apikey, "Barclays")
saveTicker("BCS")

# search ticker for Santander Bank
test <- extractPolygonTickers(apikey, "Santander")
saveTicker("SAN")

# search ticker for RBC Bank (subsidy of Royal Bank of Canada, RY)
test <- extractPolygonTickers(apikey, "RY")
saveTicker("RY")

# search ticker for Ameriprise
test <- extractPolygonTickers(apikey, "Ameriprise")
saveTicker("AMP")

# search ticker for Regions Financial Corporation
test <- extractPolygonTickers(apikey, "RF")
saveTicker("RFpB")

# search ticker for Northern Trust
test <- extractPolygonTickers(apikey, "Northern")
saveTicker("NTRS")

# search ticker for BNP Paribas
test <- extractPolygonTickers(apikey, "paribas")
saveTicker("BNPQF")

# search ticker for Discover Financial
test <- extractPolygonTickers(apikey, "Discover")
saveTicker("DFS")

# search ticker for First Citizens BancShares
test <- extractPolygonTickers(apikey, "BancShares")
saveTicker("FCNCA")

# search ticker for Synchrony Financial
test <- extractPolygonTickers(apikey, "Synchrony")
saveTicker("SYF")

# search ticker for Deutsche Bank
test <- extractPolygonTickers(apikey, "Deutsche")
saveTicker("DB")

# search ticker for New York Community Bank
test <- extractPolygonTickers(apikey, "NYCB")
saveTicker("NYCB")

# search ticker for Comerica
test <- extractPolygonTickers(apikey, "Comerica")
saveTicker("CMA")

# search ticker for First Horizon National Corporation
test <- extractPolygonTickers(apikey, "FHN")
saveTicker("FHN")

# search ticker for Raymond James Financial
test <- extractPolygonTickers(apikey, "Raymond")
saveTicker("RJF")

# search ticker for Webster Bank
test <- extractPolygonTickers(apikey, "Webster")
saveTicker("WBS")

# search ticker for Western Alliance Bank
test <- extractPolygonTickers(apikey, "western")
saveTicker("WAL")

# search ticker for Popular, Inc.
test <- extractPolygonTickers(apikey, "popular")
saveTicker("BPOP")

# search ticker for CIBC Bank USA
test <- extractPolygonTickers(apikey, "CM")
saveTicker("CM")

# search ticker for East West Bank
test <- extractPolygonTickers(apikey, "EWBC")
saveTicker("EWBC")

# search ticker for East West Bank
test <- extractPolygonTickers(apikey, "EWBC")
saveTicker("EWBC")

# search ticker for Synovus
test <- extractPolygonTickers(apikey, "Synovus")
saveTicker("SNV")

# search ticker for Valley National Bank
test <- extractPolygonTickers(apikey, "Valley")
saveTicker("VLY")

# search ticker for Credit Suisse
test <- extractPolygonTickers(apikey, "Suisse")
saveTicker("CS")

# search ticker for Mizuho Financial Group
test <- extractPolygonTickers(apikey, "Mizuho")
saveTicker("MFG")

# search ticker for Wintrust Financial
test <- extractPolygonTickers(apikey, "Wintrust")
saveTicker("WTFC")

# search ticker for Cullen/Frost Bankers, Inc.
test <- extractPolygonTickers(apikey, "cullen")
saveTicker("CFR")

saveRDS(tickers, "data/tickers.rds")
