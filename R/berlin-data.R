#' @import XML stringr
NULL

#' Queries daten.berlin.de
#' 
#' Only one of the parameters can have a value.
#' 
#' @param query a query string to search daten.berlin.de
#' @export
#' @examples
#' result <- searchBerlinData(query = "stolpersteine")
#' dataset <- parseMetaData(result[[2]]$link)
#' resource_list <- resources(dataset)
#' data <- download(resource_list[[1]])
#' 
searchBerlinData <- function(query = NA) {
  stopifnot(length(query) == 1 && is.character(query))
  search_data(query)
}

#' Parses and downloads the meta data for a dataset
#' @param dataset_url the url of the dataset
#' @export
parseMetaData <- function(dataset_url) {
  stopifnot(length(dataset_url) == 1)
  stopifnot(is.character(dataset_url))
  parsed_data <- htmlParse(dataset_url)
  title_nodeset <- xpathApply(parsed_data,  "//h1[@id='page-title']")
  title <- str_trim(xmlValue(title_nodeset[[1]]))
  resources_nodeset <- getNodeSet(parsed_data, "//div[@class='dataset_ressource']")
  resources_list <- lapply(resources_nodeset, function(res) {
    sub_doc <- xmlDoc(res)
    field_labels <- getNodeSet(sub_doc, "//div[@class='field-label']")
    field_items <- getNodeSet(sub_doc, "//div[@class='field-items']")
    cleaned_field_labels <- unlist(lapply(field_labels, function(l)str_trim(xmlValue(l))))
    cleaned_field_items <- lapply(field_items, function(l)str_trim(xmlValue(l)))
    findIndex <- function(search_key)grep(search_key, cleaned_field_labels, ignore.case = TRUE)
    data_format_index <- findIndex("format")
    hash_index <- findIndex("hash")
    url_index <- findIndex("url")
    language_index <- findIndex("sprache")
    indexExists <- function(index)length(index) == 1 && index > 0
    if (indexExists(url_index) && indexExists(hash_index) 
        && indexExists(data_format_index)
        && indexExists(language_index)) {
      res_url <- unlist(xpathApply(xmlDoc(field_items[[url_index]]),  
                                   "//a[@href]", xmlGetAttr, "href"))
      structure(list(
        url = res_url,
        hash = cleaned_field_items[[hash_index]],
        format = cleaned_field_items[[data_format_index]],
        language = cleaned_field_items[[language_index]]
      ), class = "berlin_data_resource")
    } else {
      NULL
    }
  })
  
  structure(list(
    title = title,
    resources = Filter(function(r)!is.null(r), resources_list)
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