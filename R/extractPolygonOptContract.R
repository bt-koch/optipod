extractPolygonOptContract <- function(apikey, limit=100, ticker, contract_type="call",
                                      expired="true", expiration_date.gt=NA){

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
  if(!is.na(expiration_date.gt)){
    expd.gt <- paste0("expiration_date.gt=", expiration_date.gt)
    url_ext <- paste(url_ext, expd.gt, sep="&")
  }

  # url for API request
  url <- paste(url_base, url_ext, sep="?")

  # make API request
  response <- fromJSON(url)

  return(response$results)
}
