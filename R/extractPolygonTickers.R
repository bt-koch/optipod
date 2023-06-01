extractPolygonTickers <- function(apikey, search = NA, limit=100){

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

  return(response$results)

}
