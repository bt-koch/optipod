#' extractPolygonOptContracts
#'
#' Get relevant option data for given ticker(s)
#'
#' @param apikey Personal API key for polygon.io
#' @param tickers The ticker symbol of the options contract (vector of strings)
#' @param from The start of the time window. Either a date with the format YYYY-MM-DD or a millisecond timestamp.
#' @param to The end of the time window. Either a date with the format YYYY-MM-DD or a millisecond timestamp.
#' @param adjusted Whether or not the results are adjusted for splits ("true" or "false")
#' @param limit Limit of number of queries (maximum is 50000)
#' @param database local rsqlite database to write data on
#' @param limitedAPIcalls set TRUE if free plan (only makes 5 API calls per minute)
#'
#' @return nothing, data is written on database
extractPolygonOptContracts <- function(apikey, tickers, from, to, database,
                                       adjusted="true", limit=50000,
                                       limitedAPIcalls=TRUE){

  # connect to database
  db <- dbConnect(RSQLite::SQLite(), database)

  # GET: /v2/aggs/ticker/{optionsTicker}/range/{multiplier}/{timespan}/{from}/{to}

  # base url for ticker dataset
  url_base <- "https://api.polygon.io"
  url_data <- "/v2/aggs/ticker/"
  url_base <- paste0(url_base, url_data)

  # frequency and observation period
  url_time <- paste0("/range/1/day/", from, "/", to, "?")

  # required static inputs for API request
  adj <- paste0("adjusted=", adjusted)
  key <- paste0("apikey=", apikey)
  lmt <- paste0("limit=", limit)
  url_ext <- paste(adj, lmt, key, sep="&")

  if(limitedAPIcalls){
    counter <- 1
  }

  for(ticker in tickers){

    # try to retrieve data for specific ticker
    url <- paste0(url_base, ticker, url_time, url_ext)
    response <- fromJSON(url)

    # case 1: there is data for the ticker
    if(response$queryCount>0){
      cat("\nretrieving data for", ticker)

      # extract and prepare relevant data from API request
      df <- response$results
      df$ticker <- ticker

      # write data to database
      dbWriteTable(db, name="options", value=df, row.names=FALSE, append=TRUE)

      if(nrow(df)==limit){
        warning("limit reached, possibly more options are available")
        stop()
      }

    # case 2: there is no data for the ticker
    } else {
      cat("\nno data for", ticker)
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
