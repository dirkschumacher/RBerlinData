#' @import XML
NULL

#' Queries daten.berlin.de
#' 
#' Only one of the parameters can have a value.
#' 
#' @param query a query string to search daten.berlin.de
#' @param url a url pointing to a conrete dataset
#' @export
berlin_data <- function(query = NA, url = NA) {
  stopifnot(length(query) == 1 && length(url) == 1)
  if (is.na(query) && is.na(url)) {
    stop("either query or url must have a character value")
  }
  if (!is.na(query) && !is.na(url)) {
    stop("please user either query or url for data retrieval")
  }
  if (!is.na(query)) {
    stopifnot(length(query) == 1 && is.character(query))
  }
  if (!is.na(url)) {
    stopifnot(length(url) == 1 && is.character(url))
  }
  if (!is.na(query)) {
    search_data(query)
  } else if (!is.na(url)) {
    stop("retrieval by url not implemented")
  }
}

# Searches through daten.berlin
#
# param query the query string
# param xml_url the url to the rss feed
# usage Internal
search_data <- function(query, 
                     xml_url = "http://daten.berlin.de/datensaetze/rss.xml") {
  feed = xmlParse(xml_url)
  items = getNodeSet(feed, "//item")
  cleaned_items <- lapply(items, function(item) {
    list(
      description = xmlValue(getNodeSet(item, "description")[[1]]),
      title = xmlValue(getNodeSet(item, "title")[[1]]),
      link = xmlValue(getNodeSet(item, "link")[[1]])
    )
  })
  filtered_items <- Filter(function(item) {
    search_result <- grep(query, c(item$title, item$description), 
                          ignore.case = TRUE)
    length(search_result) > 1 || search_result > 0
  }, cleaned_items)
  if (length(filtered_items) > 0) {
    structure(
      filtered_items,
      class = "berlin_data_list"
    )
  } else {
    structure(list(query = query), class = "berlin_data_query_no_results")
  }
}