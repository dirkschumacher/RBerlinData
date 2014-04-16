library(shiny)
library(BerlinData)

data = reactiveValues()

shinyServer(function(input, output) {

  queryData = reactive(searchBerlinDatasets(input$query))
  queryDF = reactive(as.data.frame(queryData()))
  
  #whichdataset = reactive(queryData()[[input$whichdataset]])
  
  output$info = reactive(
    if(inherits(queryData(), "berlin_data_query_no_results")) {
      "No results were found for your query; please try again"
    } else {
      paste("Found", length(queryData()), "datasets")
    }
    )

  output$datasettable = renderTable({
    queryDF() 
  })
  
  #output$resourcetable = renderTable({data.frame()})
  
})
