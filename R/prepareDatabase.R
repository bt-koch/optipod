prepareDatabase <- function(){

  db <- dbConnect(RSQLite::SQLite(), "data/polygonDB.rsqlite")
  dbDisconnect(db)


}
