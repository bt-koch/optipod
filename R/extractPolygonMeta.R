extractPolygonMeta <- function(apikey, ticker){

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
