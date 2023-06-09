#' extractFrench
#'
#' This function automatically downloads the relevant csv file for risk free
#' rates from Kenneth R. Frenchs Website (https://mba.tuck.dartmouth.edu/pages/faculty/ken.french/data_library.html)
#'
#' @param path_out path in which CSV should be unpacked
#'
#' @return Fama/French 3 Factors daily data
extractFrench <- function(path_out = "./data"){

  # download URL
  url <- "https://mba.tuck.dartmouth.edu/pages/faculty/ken.french/ftp/F-F_Research_Data_Factors_daily_CSV.zip"

  # download and unpack
  temp <- tempfile()
  download.file(url, temp)
  unzip(temp, exdir=path_out)
  unlink(temp)

  # read the data
  file <- file.path(path_out, "F-F_Research_Data_Factors_daily.CSV")
  data <- read.csv(file, skip=4)

  return(data)

}
