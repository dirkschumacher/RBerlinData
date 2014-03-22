#' @export 
#' @method resources berlin_data_dataset
resources.berlin_data_dataset <- function(dataset, ...) {
  dataset$resources
}

#' Gets the resources of an object
#' @export
resources <- function(dataset, ...) {
  UseMethod("resources")
}