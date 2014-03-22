#' @export
summary.berlin_data_list <- function(object, ...) {
  list(
    length = length(object),
    data_sets = unlist(lapply(object, function(d)d$title))
  )
}