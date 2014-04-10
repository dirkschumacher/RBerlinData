#' @export
summary.berlin_data_resource <- function(object, ...) {
  cat(paste0("Title: '", object$title,"';Format: ", object$format))
}

#' @export
summary.berlin_data_resource_list <- function(object, ...) {
  cat(paste(length(object), "resources"))
  cat("\n")
  for (i in 1:length(object)) {
    cat(paste0(i,": "))
    cat(summary(object[[i]]))
    cat("\n")
  }
}

#' @export
summary.berlin_data_dataset <- function(object, ...) {
  cat(object$title)
  cat("\n")
  cat(summary(object$resources))
}

#' Downloads a resource
#' @export
#' @method download berlin_data_resource
#' @param resource a resource of type berlin_data_resource
download.berlin_data_resource <- function(resource) {
  result <- downloadFormat(resource$url, resource$format)
  result
}

#' Calls appropriate function for download format
#' @param url url of file location
#' @param format string specifying download format, in c("CSV", "JSON", "XML")
#' @param ... optional additional arguments to download function
downloadFormat <- function(url, format, ...) {
  switch(format,
         CSV = read.csv(url, ...),
         JSON = downloadJSON(url, ...),
         XML = downloadXML(url, ...))
}

#' Downloads json file
#' @param json.url url of json file location
#' @param parse.to.df logical: should the function try to parse the JSON output into a data.frame?
#' @param ... optional additional arguments to download function
downloadJSON <- function(json.url, parse.to.df=TRUE, ...) {
  require(rjson)
  result <- fromJSON(file=json.url, ...)
  if(parse.to.df) {
    stopifnot(length(result) == 4 &
                names(result) == c("messages", "results", "index", "item") &
                class(result$index) == "list" & 
                length(result$index) >= 1)
    data <- result$index
    data <- lapply(data, unlist)
    data <- do.call(rbind, data)
    result <- data.frame(data) 
  }
  result
}

#' Downloads xml file
#' @param xml.url url of xml file location
#' @param parse.to.df logical: should the function try to parse the XML output into a data.frame?
#' @param ... optional additional arguments to download function
downloadXML = function(xml.url, parse.to.df=TRUE, ...) {
  result <- xmlTreeParse(file=xml.url, getDTD=FALSE, ...)
  stopifnot(length(result) == 3 &
              names(result) == c("file", "version", "children"))
  result <- xmlRoot(result)
  if (parse.to.df) {
    stopifnot("XMLNode" %in% class(result) &
                names(result) == c("messages", "results", "index", "item") & 
                length(result[['index']]) >= 1)
    items <- getNodeSet(result[['index']], "//item")
    ncols <- max(sapply(items, xmlSize))
    data <- lapply(items, 
                   function(item) {
                     datarow <- sapply(xmlChildren(item), xmlValue)
                     stopifnot(length(datarow) == ncols)
                     if(class(datarow)=="list") { #  handle missing values
                       datarow[sapply(datarow, length)==0] = ''
                       datarow <- unlist(datarow)
                     }
                     datarow
                   })
    data <- do.call(rbind, data)
    result <- data.frame(data)
  }
  result
}

#' Downloads a resource
#' @param resource a resource which can be downloaded 
#' @export
download <- function(resource) {
  UseMethod("download")
}
