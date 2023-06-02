#' extractPolygonStock
#'
#' @param apikey Personal API key for polygon.io
#' @param limit Limit the number of results returned (maximum is 50000)
#' @param ticker Ticker symbol of the stock/equity
#' @param from The start of the aggregate time window. Either a date with the format YYYY-MM-DD or a millisecond timestamp
#' @param to The end of the aggregate time window. Either a date with the format YYYY-MM-DD or a millisecond timestamp
#' @param adjusted Whether or not the results are adjusted for splits
#' @param sort Sort the results by timestamp (asc or desc)
#'
#' @return historical stock data
#' @export
#'
#' @examples
extractPolygonStock <- function(apikey, limit=100, ticker, from, to,
                                adjusted="true", sort="asc"){

  # GET: /v2/aggs/ticker/{stocksTicker}/range/{multiplier}/{timespan}/{from}/{to}

  # base url for ticker dataset
  url_base <- "https://api.polygon.io"
  url_data <- "/v2/aggs/ticker/"
  url_base <- paste0(url_base, url_data)

  # required inputs for API request
  url_base <- paste0(url_base, ticker, "/range/1/day/")
  url_base <- paste0(url_base, from, "/", to, "?")

  lmt <- paste0("limit=", limit)
  adj <- paste0("adjusted=", adjusted)
  srt <- paste0("sort=", sort)
  url_ext <- paste(lmt, adj, srt, sep="&")

  # url for API request
  url <- paste(url_base, url_ext, sep="?")

  # make API request
  response <- fromJSON(url)

  return(response$results)

}
