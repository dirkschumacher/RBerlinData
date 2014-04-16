library(shiny)

shinyUI(fluidPage(
  titlePanel("Berlin Data Explorer"),
  sidebarLayout(
    sidebarPanel(
      textInput(inputId="query", label="Your Query Here:", value="Vornamen"),
      submitButton("Submit Query")#,
      #conditionalPanel(
      #  condition = "nrow(output.datasettable) > 0",
      #  textInput("whichdataset", "Select Dataset #"),
      #  submitButton("Get Dataset Metadata")
      #  )
      ),
    mainPanel(
      verbatimTextOutput(outputId="info"),
      tableOutput(outputId="datasettable")
    ) #,
    #conditionalPanel(
    #  condition="nrow(output.datasettable) > 0",
    #  tableOutput(outputId="resourcetable")
    #)
    )
  ))