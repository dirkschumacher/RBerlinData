library(shiny)

shinyUI(fluidPage(
  title="Berlin Data Explorer",
  fluidRow(
    column(12,
           tabsetPanel(
             tabPanel("Query",
                      column(2,
                             wellPanel(
                               textInput(inputId="query", 
                                         label="Your Query Here:", 
                                         value="Vornamen"),
                               submitButton("Search Berlin Datasets") 
                             )
                      ),
                      column(10,
                             mainPanel(
                               verbatimTextOutput(outputId="query_info"),
                               tableOutput(outputId="query_table")
                             )
                      )
             ),
             tabPanel("Dataset Metadata",
                      column(2,
                             wellPanel(
                               textInput("which_dataset", 
                                         "Select dataset #\n
                                           from datasets found by query",
                                         0),
                               submitButton("Get Dataset Metadata")
                             )
                      ),
                      column(10,
                             mainPanel(
                               verbatimTextOutput(outputId="dataset_info"),
                               tableOutput(outputId="dataset_table")
                             )
                      )
             ),
             tabPanel("Data Resource",
                      column(2,
                             wellPanel(
                               textInput("which_resource", 
                                         "Select resource #\n
                                         from resources in dataset",
                                         0),
                               submitButton("Get Data Resource"),
                               br(),
                               downloadButton(outputId="download_data_resource",
                                              "Download Data Resource")
                             )
                             ),
                      column(10,
                             mainPanel(
                               verbatimTextOutput(outputId="data_resource_info"),
                               tableOutput(outputId="data_resource_table")
                             )
                      ))
           )
    ) 
  )
)
)