#' @export
summary.berlin_data_resource <- function(object, ...) {
  object
}

#' Downloads a resource
#' @export
#' @method download berlin_data_resource
download.berlin_data_resource <- function(resource, ...) {
  NULL
}

#' Downloads a resource
#' @export
download <- function(resource, ...) {
  UseMethod("download")
}