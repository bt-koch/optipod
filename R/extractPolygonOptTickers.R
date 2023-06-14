#' extractPolygonOptTickers
#'
#' Function to get all option contract (tickers) for a specific underlying.
#'
#' @param apikey Personal API key for polygon.io
#' @param limit Limit the number of results returned (maximum is 1000)
#' @param contract_type Type of contract ("call" or "put")
#' @param expired Whether to query for expired or not expired contracts ("true" or "false")
#' @param expiration_date.gte contract expiration date greater than or equal to (format YYYY-MM-DD)
#' @param expiration_date.lte contract expiration date smaller than or equal to (format YYYY-MM-DD)
#' @param tickers tickers of the underlyings (vector of character string)
#' @param limitedAPIcalls set TRUE if free plan (only makes 5 API calls per minute)
#' @param database local rsqlite database to write data on
#'
#' @return nothing, data is written on database
extractPolygonOptTickers <- function(apikey, tickers, database, limitedAPIcalls,
                                     limit=1000, contract_type="call",
                                     expired="true",
                                     expiration_date.gte=NA,
                                     expiration_date.lte=NA){

  # connect to database
  db <- dbConnect(RSQLite::SQLite(), database)

  # GET: /v3/reference/options/contracts

  # base url for ticker dataset
  url_base <- "https://api.polygon.io"
  url_data <- "/v3/reference/options/contracts"
  url_base <- paste0(url_base, url_data)

  # required inputs for API request
  lmt <- paste0("limit=", limit)
  # tckr <- paste0("underlying_ticker=", ticker)
  key <- paste0("apikey=", apikey)
  type <- paste0("contract_type=", contract_type)
  exp <- paste0("expired=", expired)
  url_ext <- paste(lmt, key, type, exp, sep="&")

  # optional inputs for API request
  if(!is.na(expiration_date.gte)){
    expd.gte <- paste0("expiration_date.gte=", expiration_date.gte)
    url_ext <- paste(url_ext, expd.gte, sep="&")
  }
  if(!is.na(expiration_date.lte)){
    expd.lte <- paste0("expiration_date.lte=", expiration_date.lte)
    url_ext <- paste(url_ext, expd.lte, sep="&")
  }

  if(limitedAPIcalls){
    counter <- 1
  }

  for(ticker in tickers){

    cat("\noption ticker API request for", ticker)

    # url for API request
    tckr <- paste0("underlying_ticker=", ticker)
    url_ext_temp <- paste(url_ext, tckr, sep="&")
    url <- paste(url_base, url_ext_temp, sep="?")

    # API request
    response <- fromJSON(url)
    response <- response$results

    if(length(response) == 0){
      cat("\nno option contracts found for ticker ", ticker)
    } else {
      # only keep defined columns
      response <- response[, c("cfi", "contract_type", "exercise_style",
                               "expiration_date", "primary_exchange",
                               "shares_per_contract", "strike_price",
                               "ticker", "underlying_ticker")]
      # write data to database
      dbWriteTable(db, name="tickers", value=response, row.names=FALSE, append=TRUE)

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
