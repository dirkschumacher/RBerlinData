#' @export
summary.berlin_data_resource <- function(object, ...) {
  cat(paste0("Title: '", object$title,"';Format: ", object$format))
}

#' @export
summary.berlin_data_resource_list <- function(object, ...) {
  cat(paste(length(object), "resources"))
  cat("\n")
  for (i in 1:length(object)) {
    cat(summary(object[[1]]))
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
  stopifnot('format' %in% names(resource), 
            'url' %in% names(resource))
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
         JSON = downloadJson(url, ...),
         XML = downloadXml(url, ...))
}

#' Downloads json file
#' @param json.url url of json file location
#' @param parse.to.df logical: should the function try to parse the JSON output into a data.frame?
#' @param ... optional additional arguments to download function
downloadJSON <- function(json.url, parse.to.df=TRUE, ...) {
  require(rjson)
  result <- fromJSON(file=json.url, ...)
  if(parse.to.df) {
    data <- result[[3]]
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
  result <- xmlTreeParse(xml.url, ...)
  if (parse.to.df) {
    data <- result[[1]][[1]][[3]]
    # TODO this doesn't work
    data1 <- lapply(data, 
                   function(item) {
                     datarow <- sapply(xmlChildren(item), xmlValue)
                     if(class(datarow)=="list") datarow <- unlist(datarow)
                     print(names(datarow)) 
                     print(names(item))
                     print(class(datarow))
                     datarow
                   })
    data <- do.call(rbind, data)
    dimnames()
    result1 <- data.frame(data)
  }
  result
}

#' Downloads a resource
#' @param resource a resource which can be downloaded 
#' @export
download <- function(resource) {
  UseMethod("download")
}