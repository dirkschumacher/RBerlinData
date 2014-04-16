library(shiny)
library(BerlinData)

data = reactiveValues()

shinyServer(function(input, output) {

  queryData = reactive(searchBerlinDatasets(input$query))
  queryDF = reactive(as.data.frame(queryData()))
  message(str(isolate(queryDF())))
  
  output$info = reactive(
    if(inherits(queryData(), "berlin_data_query_no_results")) {
      "No results were found for your query; please try again"
    } else {
      paste("Found", length(queryData()), "datasets")
    }
    )

  output$datasettable = renderDataTable({
    queryDF() 
  })
  
  #output$resourcetable = data.frame()
  
})
