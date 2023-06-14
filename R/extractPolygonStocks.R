#' extractPolygonStocks
#'
#' Get relevant stock data for given ticker(s)
#'
#' @param apikey Personal API key for polygon.io
#' @param tickers Limit the number of results returned (maximum is 1000)
#' @param database local rsqlite database to write data on
#' @param from The start of the time window. Either a date with the format YYYY-MM-DD or a millisecond timestamp.
#' @param to The end of the time window. Either a date with the format YYYY-MM-DD or a millisecond timestamp.
#' @param limitedAPIcalls set TRUE if free plan (only makes 5 API calls per minute)
#' @param limit Limit of number of queries (maximum is 50000)
#' @param adjusted Whether or not the results are adjusted for splits ("true" or "false")
#'
#' @return nothing, data is written on database
extractPolygonStocks <- function(apikey, tickers, database, from, to,
                                 limitedAPIcalls, limit=50000, adjusted="true"){

  # connect to database
  db <- dbConnect(RSQLite::SQLite(), database)

  # GET: /v2/aggs/ticker/{stocksTicker}/range/{multiplier}/{timespan}/{from}/{to}

  # base url for ticker dataset
  url_base <- "https://api.polygon.io"
  url_data <- "/v2/aggs/ticker/"
  url_base <- paste0(url_base, url_data)

  # time component
  url_time <- paste0("/range/1/day/", from, "/", to)

  # required inputs for API request
  lmt <- paste0("limit=", limit)
  key <- paste0("apikey=", apikey)
  adj <- paste0("adjusted=", adjusted)
  url_ext <- paste(lmt, key, adj, sep="&")

  if(limitedAPIcalls){
    counter <- 1
  }

  for(ticker in tickers){

    cat("\nstock ticker API request for", ticker)

    # url for API request
    url <- paste0(url_base, ticker, url_time, "?", url_ext)

    # API request
    response <- fromJSON(url)
    response <- response$results
    response$ticker <- ticker

    if(length(response) == 0){
      cat("\nno option contracts found for ticker ", ticker)
    } else {
      # write data to database
      response <- response[, c("ticker", "t", "c")]
      dbWriteTable(db, name="stocks", value=response, row.names=FALSE, append=TRUE)

      if(nrow(response)==limit){
        warning("limit reached, possibly more options are available")
      }
    }

    if(limitedAPIcalls){

      if(counter == 5){
        counter <- 0
        cat("\ngoing to sleep... ")
        Sys.sleep(60)
        cat("waking up!")
      }
      counter <- counter+1
    }
  }

  # disconnect from database
  dbDisconnect(db)
}
