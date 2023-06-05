#' extractPolygonOptContracts
#'
#' desc
#'
#' @param apikey
#' @param tickers
#' @param from
#' @param to
#' @param adjusted
#' @param limit
#' @param database
#' @param limitedAPIcalls
#'
#' @return
#' @export
#'
#' @examples
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
    counter = 1
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

    # case 2: there is no data for the ticker
    } else {
      cat("\nno data for", ticker)
    }

    if(limitedAPIcalls & counter == 5){
      counter <- 0
      cat("\ngoing to sleep... ")
      Sys.sleep(60)
      cat("waking up!")
    }

    if(limitedAPIcalls){
      counter <- counter+1
    }

  }

  # disconnect from database
  dbDisconnect(db)

}
