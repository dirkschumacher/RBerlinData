library(shiny)
library(BerlinData)
library(ggplot2)

shinyServer(function(input, output) {

  #### Data Explorer ####
  
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

  output$query_table = renderDataTable({ queryDF() })
  
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
  
  output$dataset_table = renderDataTable({ datasetMetaDataDF() })

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
            #"Showing", ifelse(nrow(dataResource()) < 6, nrow(dataResource()), 6), 
            "Rows:", nrow(dataResource()), "\n",
            "Click 'Download' to download data resource as a CSV.")
  })
  
  output$data_resource_table = renderDataTable({ dataResource() })
  
  output$download_data_resource = downloadHandler(
    filename = function() paste0("berlin_data_resource_", 
                                 gsub('\\s', '-', Sys.time()), ".csv"),
    content = function(file) {
      write.csv(dataResource(), file=file)
    })

  #### Visualizations ####
  
  allDatasets = reactive({searchBerlinDatasets('')})
  
  allDatasetsDF = reactive({
    data = data.frame(allDatasets())
    creators_sort = sort(table(data$creator))
    locale = Sys.getlocale(category="LC_TIME")
    Sys.setlocale(category="LC_TIME", locale="C")
    data = transform(data, 
                     pub_date = strptime(pub_date, format="%a, %d %b %Y %X %z"),
                     creator = factor(creator, levels=names(creators_sort)))
    Sys.setlocale(category="LC_TIME", locale=locale)
    data
  })
  
  plotAllDatasets = reactive({
    plot =       ggplot(allDatasetsDF()) +
      aes_string(x=paste(input$datasets_x)) +
      geom_histogram(fill="#C27D38") +
      theme(axis.text.x = element_text(hjust=1, angle=45))  
    if (input$datasets_x == "creator") plot = plot + coord_flip()
    if (input$datasets_x == "pub_date_filtered") 
      plot = plot %+% subset(allDatasetsDF(), pub_date > as.POSIXct('2000-01-01')) + aes_string(x="pub_date")
    plot
  })
  
  allDataResources = reactive({
    data = data.frame(getDatasetMetaData(allDatasets()))
    data
  })

  plotAllDataResources = reactive({
    plot =       ggplot(allDataResources()) +
      aes_string(x=paste(input$data_resources_x)) +
      geom_histogram(fill="#C27D38") +
      theme(axis.text.x = element_text(hjust=1, angle=45))  
    if (input$data_resources_x == "") return()
    plot
  })
  
  output$datasets_plot_info = renderText({ 
    switch(input$datasets_x,
           "creator" = "Number of datasets on daten.berlin.de by creator",
           "pub_date" = "Number of datasets on daten.berlin.de by date of publication\n (unfiltered metadata)",
           "pub_date_filtered" = "Number of datasets on daten.berlin.de by date of publication\n (filtered for plausible dates)")
    })
  
  output$datasets_plot = renderPlot({ 
    print(plotAllDatasets()) 
    })
  
  output$data_resources_plot_info = renderText({ 
    switch(input$data_resources_x,
           "format" = "Number of data resources on daten.berlin.de by resource format",
           "language" = "Number of data resources on daten.berlin.de by resource language",
           "scheme" = "Number of data resources on daten.berlin.de by URL scheme")
  })
 
  output$data_resources_plot = renderPlot({ print(plotAllDataResources()) })
  
})
