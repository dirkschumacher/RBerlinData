library(shiny)
library(BerlinData)

shinyServer(function(input, output) {

  queryData = reactive(searchBerlinDatasets(input$query))
  queryDF = reactive(as.data.frame(queryData()))
  
  datasetMetaData = reactive({
    if(as.numeric(input$which_dataset) == 0 | as.numeric(input$which_dataset) > nrow(queryDF())) 
      list()
    else {
        getDatasetMetaData(
          paste(queryDF()[as.numeric(input$which_dataset), 'link'])
          )
    }})
  
  datasetMetaDataDF = reactive({
    if(as.numeric(input$which_dataset) == 0 | as.numeric(input$which_dataset) > nrow(queryDF())) 
      data.frame(title=NA, resources=NA)
    else {
      as.data.frame(datasetMetaData())   
    }})
  
  dataResource = reactive({
    if(as.numeric(input$which_resource) == 0 | as.numeric(input$which_resource) > nrow(datasetMetaDataDF())) 
      data.frame(data=NA)
    else {
      download(
        resources(datasetMetaData())[[as.numeric(input$which_resource)]]
      )  
    }})
  
  output$query_info = renderText(
    ifelse(inherits(queryData(), "berlin_data_query_no_results"),
           "No results were found for your query; please try again",
           paste0("Found ", length(queryData()), " dataset", 
                  ifelse(length(queryData()) > 1, "s", ""),".\n",
                 "Proceed to the Dataset tab to get metadata for any dataset."))
  )

  output$query_table = renderTable({ queryDF() })
  
  output$dataset_info = renderText(
    ifelse(as.numeric(input$which_dataset) == 0,
           "No dataset selected",
           ifelse(as.numeric(input$which_dataset) > nrow(queryDF()),
                  paste0("Please select ", 
                         ifelse(nrow(queryDF()) > 1,"one of the ", "the "),
                        nrow(queryDF()), 
                        " dataset", ifelse(nrow(queryDF()) > 1,"s", ""),
                        " in the list"),
                  paste("Selected dataset #", 
                        as.numeric(input$which_dataset), "of",
                        nrow(queryDF()), "found by query.\n",
                        "Title:", queryDF()$title[[as.numeric(input$which_dataset)]],"\n",
                        "Found", nrow(datasetMetaDataDF()), "resources in dataset.\n",
                        "Proceed to the Data Resource tab to download a resource.")))
  )
  
  output$dataset_table = renderTable({ datasetMetaDataDF() })

  output$data_resource_info = renderText({
    if (as.numeric(input$which_resource) == 0)
           "No data resource selected"
    else if(as.numeric(input$which_resource) > nrow(datasetMetaDataDF()))
                  paste("Please select one of the", 
                        nrow(datasetMetaDataDF()), 
                        "data resources in the list")
    else if(datasetMetaDataDF()$scheme[as.numeric(input$which_resource)] == "https")
      paste("Selected resource #", 
            input$which_resource, "of",
            nrow(datasetMetaDataDF()), "found for dataset.\n",
            "Title:", queryDF()$title[[as.numeric(input$which_dataset)]],"\n",
            "URL:", datasetMetaDataDF()$url[[as.numeric(input$which_resource)]],"\n",
            "Unfortunately, R does not support downloads from an https:// source.")
    else if(!(datasetMetaDataDF()$format[as.numeric(input$which_resource)] %in% c("CSV", "JSON", "TXT", "XML")))
      paste("Selected resource #", 
            input$which_resource, "of",
            nrow(datasetMetaDataDF()), "found for dataset.\n",
            "Title:", queryDF()$title[[as.numeric(input$which_dataset)]],"\n",
            "URL:", datasetMetaDataDF()$url[[as.numeric(input$which_resource)]],"\n",
            "Format:", datasetMetaDataDF()$format[[as.numeric(input$which_resource)]],"\n",
            "Unfortunately, BerlinData does not support download of this format.")
    else if(is.null(dataResource()))
      paste("Selected resource #", 
            input$which_resource, "of",
            nrow(datasetMetaDataDF()), "found for dataset.\n",
            "Title:", queryDF()$title[[as.numeric(input$which_dataset)]],"\n",
            "URL:", datasetMetaDataDF()$url[[as.numeric(input$which_resource)]],"\n",
            "An error occurred in downloading this resource. Please try manual download.")
    else
      paste("Selected resource #", 
            input$which_resource, "of",
            nrow(datasetMetaDataDF()), "found for dataset.\n",
            "Title:", queryDF()$title[[as.numeric(input$which_dataset)]],"\n",
            "URL:", datasetMetaDataDF()$url[[as.numeric(input$which_resource)]],"\n",
            "Showing", ifelse(nrow(dataResource()) < 6, nrow(dataResource()), 6), 
            "of", nrow(dataResource()), "rows in this resource.\n",
            "Click 'Download' to download data resource as a CSV.")
  })
  
  output$data_resource_table = renderTable({ head(dataResource()) })
  
  output$download_data_resource = downloadHandler(
    filename = function() paste0("berlin_data_resource_", 
                                 gsub('\\s', '-', Sys.time()), ".csv"),
    content = function(file) {
      write.csv(dataResource(), file=file)
    }
    )
  
})
