#' Gets the resources from a dataset
#' @export 
#' @method resources berlin_data_dataset
#' @param object a dataset with a list of resources
resources.berlin_data_dataset <- function(object) {
  object$resources
}

#' Gets the resources from an object
#' @param object an object with resources
#' @export
resources <- function(object) {
  UseMethod("resources")
}