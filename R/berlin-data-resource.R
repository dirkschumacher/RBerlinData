#' @export
summary.berlin_data_resource <- function(object, ...) {
  object
}

#' Downloads a resource
#' @export
#' @method download berlin_data_resource
#' @param resource a resource of type berlin_data_resource
download.berlin_data_resource <- function(resource) {
  NULL
}

#' Downloads a resource
#' @param resource a resource which can be downloaded 
#' @export
download <- function(resource) {
  UseMethod("download")
}