#' @import XML stringr
NULL

#' Queries daten.berlin.de
#' 
#' Only one of the parameters can have a value.
#' 
#' @param query a query string to search daten.berlin.de
#' @param url a url pointing to a concrete dataset
#' @export
#' @examples
#' result <- berlin_data(query = "stolpersteine")
#' dataset <- load_metadata(result[[2]]$link)
#' resources <- resources(dataset)
#' data <- fetch(resources[[2]])
#' 
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
    load_metadata(url)
  }
}

#' Parses and downloads the meta data for a dataset
#' @param dataset_url the url of the dataset
#' @export
load_metadata <- function(dataset_url) {
  stopifnot(length(dataset_url) == 1)
  stopifnot(is.character(dataset_url))
  parsed_data <- htmlParse(dataset_url)
  title_nodeset <- xpathApply(parsed_data,  "//h1[@id='page-title']")
  title <- str_trim(xmlValue(title_nodeset[[1]]))
  resources_nodeset <- getNodeSet(parsed_data, "//div[@class='dataset_ressource']")
  resources <- lapply(resources_nodeset, function(res) {
    sub_doc <- xmlDoc(res)
    field_labels <- getNodeSet(sub_doc, "//div[@class='field-label']")
    field_items <- getNodeSet(sub_doc, "//div[@class='field-items']")
    res_url <- unlist(xpathApply(xmlDoc(field_items[[1]]),  
                                 "//a[@href]", xmlGetAttr, "href"))
    hash <- str_trim(xmlValue(field_items[[2]]))
    data_format <- str_trim(xmlValue(field_items[[3]]))
    language <- str_trim(xmlValue(field_items[[4]]))
    structure(list(
      url = res_url,
      hash = hash,
      format = data_format,
      language = language
    ), class = "berlin_data_resource")
  })
  structure(list(
    title = title,
    resources = resources
  ), class = "berlin_data_dataset")
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