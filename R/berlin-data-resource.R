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
#' @param resource a resource which can be downloaded 
#' @param ... optional additional arguments to download function
#' @export
download <- function(resource, ...) {
  UseMethod("download")
}


#' Default fallback method for download
#' Indicates unsupported file format
#' @param resource a resource which can be downloaded
#' @param ... optional additional arguments
#' @export
download.default <- function(resource, ...) {
  stopifnot(length(resource) >= 1)
  message('Attempted to download:')
  message(resource)
  message('File format:')
  message(class(resource))
  message('Unfortunately, BerlinData does not yet support automatic download for this format.')
}

#' Downloads a resource
#' @param resource a resource of type berlin_data_resource
#' @param ... optional additional arguments to download function
#' @export
download.berlin_data_resource <- function(resource, ...) {
  resource_link <- resource$url
  class(resource_link) <- resource$format
  result <- download(resource_link, ...)
  result
}

#' Downloads CSV
#' @param resource url of csv file location
#' @param sep field separator
#' @param ... optional additional arguments to download function
#' @export
download.CSV <- function(resource, ..., sep=';') {
  result <- read.csv(resource, sep=sep, ...)
  result
}

#' Downloads json file
#' @param resource url of json file location
#' @param parse.to.df logical: should the function try to parse the JSON output into a data.frame?
#' @param ... optional additional arguments to download function
#' @export
download.JSON <- function(resource, ..., parse.to.df=TRUE) {
  require(rjson)
  result <- fromJSON(file=resource, ...)
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
#' @param resource url of xml file location
#' @param parse.to.df logical: should the function try to parse the XML output into a data.frame?
#' @param ... optional additional arguments to download function
#' @export
download.XML = function(resource, ..., parse.to.df=TRUE) {
  result <- xmlTreeParse(file=resource, getDTD=FALSE, ...)
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

#' Downloads xls file
#' Interestingly, these appear to actually be HTML files.
#' @param resource url of xls file location
#' @param parse.to.df logical: should the function try to parse the html output into a data.frame?
#' @param ... optional additional arguments to download function
#' @export
download.XLS <- function(resource, ..., parse.to.df=TRUE) {
  result_con <- url(resource, open="r", ...)
  result <- readLines(result_con, warn=FALSE) # all these files lack final EOLS: turn off warning
  close(result_con)
  result <- paste(result, collapse=' ')
  if (length(result) == 0 | substr(result,1,6) != '<html>') 
    stop(paste("XLS autodownload unsuccessful: you can attempt manual download from", resource))
  result <- htmlParse(result)
  if(parse.to.df) {
    stopifnot(length(result) &
                "HTMLInternalDocument" %in% class(result))
    data <- readHTMLTable(result)
    stopifnot(length(data) == 1 & class(data[[1]]) == "data.frame")
    result <- data[[1]]
  }
  result
}
