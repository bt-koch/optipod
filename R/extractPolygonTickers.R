#' extractPolygonTickers
#'
#' @param apikey Personal API key for polygon.io
#' @param search Search for terms within the ticker and/or company name
#' @param limit Limit the number of results returned (maximum is 1000)
#'
#' @return tickers of Stocks/Equities, Indices, Forex, and Crypto
#' @export
#'
#' @examples
extractPolygonTickers <- function(apikey, search = NA, limit=100){

  # GET: /v3/reference/tickers

  # base url for ticker dataset
  url_base <- "https://api.polygon.io"
  url_data <- "/v3/reference/tickers"
  url_base <- paste0(url_base, url_data)

  # required inputs for API request
  lmt <- paste0("limit=", limit)
  key <- paste0("apikey=", apikey)
  url_ext <- paste(lmt, key, sep="&")

  # optional inputs for API request
  if(!is.na(search)){
    srch <- paste0("search=", search)
    url_ext <- paste(url_ext, srch, sep="&")
  }

  # url for API request
  url <- paste(url_base, url_ext, sep="?")

  # make API request
  response <- fromJSON(url)

  # extract relevant data
  df <- response$results

  if(length(df) == 0){
    warning("No tickers found for ", srch)
    return(NULL)
  } else if(nrow(df) == 1000){
    warning("Attention, API request limit reached. Possible more data available.")
  }

  return(df)

}
