#' @export
summary.berlin_data_query_no_results <- function(object, ...) {
  cat("Your search did not return any results")
  invisible()
}