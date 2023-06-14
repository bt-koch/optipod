#' extractPolygonMeta
#'
#' get Metadata of selected ticker from polygon API
#'
#' @param apikey Personal API key for polygon.io
#' @param ticker ticker for underlying
#'
#' @return metadata of underlying firm
extractPolygonMeta <- function(apikey, ticker){

  # GET: /v3/reference/tickers

  # base url for ticker dataset
  url_base <- "https://api.polygon.io"
  url_data <- "/v3/reference/tickers"
  url_base <- paste0(url_base, url_data)

  # required inputs for API request
  tckr <- paste0("ticker=", ticker)
  key <- paste0("apikey=", apikey)
  url_ext <- paste(tckr, key, sep="&")

  # url for API request
  url <- paste(url_base, url_ext, sep="?")

  # make API request
  response <- fromJSON(url)

  return(response$results)

}
