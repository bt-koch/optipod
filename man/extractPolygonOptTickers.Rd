% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/extractPolygonOptTickers.R
\name{extractPolygonOptTickers}
\alias{extractPolygonOptTickers}
\title{extractPolygonOptTickers}
\usage{
extractPolygonOptTickers(
  apikey,
  limit = 100,
  ticker,
  contract_type = "call",
  expired = "true",
  expiration_date.gte = NA
)
}
\arguments{
\item{apikey}{Personal API key for polygon.io}

\item{limit}{Limit the number of results returned (maximum is 1000)}

\item{ticker}{Underlying stock ticker for related contracts}

\item{contract_type}{Type of contract (call or put)}

\item{expired}{Whether to query for expired or not expired contracts}

\item{expiration_date.gte}{contract expiration date greater than or equal to (format YYYY-MM-DD)}
}
\value{
historical option contracts
}
\description{
Function to get all option contract (tickers) for a specific underlying.
}