#' @export
summary.berlin_data_list <- function(object, ...) {
  cat(paste0(length(object), " datasets"))
  for(i in 1:length(object)) {
    cat("\n")
    cat(paste0(i, ": ", object[[i]]$title))
  }
}
