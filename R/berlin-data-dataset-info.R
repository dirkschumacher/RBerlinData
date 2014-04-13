## methods for BerlinData generic functions ##

#' @export
getDatasetMetaData.berlin_data_dataset_info = function(where, ...) {
  link <- where$link
  result <- parseMetaData(link, ...)
  result
}

## methods for base generic functions ##

# roxygen2 doesn't recognize 'is.x' as an S3 method, requires manual documentation
#' @method berlin_data_dataset_info is
is.berlin_data_dataset_info <- function(x) inherits(x, "berlin_data_dataset_info")
