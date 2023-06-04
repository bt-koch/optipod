#' extractPolygonOptTickers
#'
#' Function to get all option contract (tickers) for a specific underlying.
#'
#' @param apikey Personal API key for polygon.io
#' @param limit Limit the number of results returned (maximum is 1000)
#' @param ticker Underlying stock ticker for related contracts
#' @param contract_type Type of contract (call or put)
#' @param expired Whether to query for expired or not expired contracts
#' @param expiration_date.gte contract expiration date greater than or equal to (format YYYY-MM-DD)
#'
#' @return historical option contracts
#' @export
#'
#' @examples
extractPolygonOptTickers <- function(apikey, limit=100, ticker, contract_type="call",
                                     expired="true", expiration_date.gte=NA){

  # GET: /v3/reference/options/contracts

  # base url for ticker dataset
  url_base <- "https://api.polygon.io"
  url_data <- "/v3/reference/options/contracts"
  url_base <- paste0(url_base, url_data)

  # required inputs for API request
  lmt <- paste0("limit=", limit)
  tckr <- paste0("underlying_ticker=", ticker)
  key <- paste0("apikey=", apikey)
  type <- paste0("contract_type=", contract_type)
  exp <- paste0("expired=", expired)
  url_ext <- paste(lmt, tckr, key, type, exp, sep="&")

  # optional inputs for API request
  if(!is.na(expiration_date.gte)){
    expd.gt <- paste0("expiration_date.gte=", expiration_date.gte)
    url_ext <- paste(url_ext, expd.gt, sep="&")
  }

  # url for API request
  url <- paste(url_base, url_ext, sep="?")

  # make API request
  response <- fromJSON(url)

  return(response$results)
}
