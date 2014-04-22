library(shiny)

shinyUI(navbarPage("BerlinData",
                   id="nav",
                   tabPanel("Data Explorer",
                            fluidRow(
                                titlePanel("Data Explorer"),
                                tabsetPanel(
                                  tabPanel("Query",
                                           column(
                                             3,
                                             wellPanel(
                                               textInput(inputId="query", 
                                                         label="Your Query Here:", 
                                                         value="Vornamen"),
                                               submitButton("Search Berlin Datasets"))),
                                           column(
                                             9,
                                             mainPanel(
                                               conditionalPanel(
                                                 "!$('#query_table .dataTables_wrapper').length || $('html').hasClass('shiny-busy')",
                                                 p("Running query...")
                                               ),
                                               verbatimTextOutput(outputId="query_info"),
                                               dataTableOutput(outputId="query_table")))),
                                  tabPanel("Dataset Metadata",
                                           column(
                                             3,
                                             wellPanel(
                                               textInput("which_dataset", 
                                                         "Select dataset #\n
                                           from datasets found by query",
                                                         1),
                                               submitButton("Get Dataset Metadata"))),
                                           column(
                                             9,
                                             mainPanel(
                                               verbatimTextOutput(outputId="dataset_info"),
                                               dataTableOutput(outputId="dataset_table")))),
                                  tabPanel("Data Resource",
                                           column(
                                             3,
                                             wellPanel(
                                               textInput("which_resource", 
                                                         "Select resource #\n
                                         from resources in dataset",
                                                         1),
                                               submitButton("Get Data Resource"),
                                               br(),
                                               downloadButton(outputId="download_data_resource",
                                                              "Download Data Resource"))),
                                           column(
                                             9,
                                             mainPanel(
                                               verbatimTextOutput(outputId="data_resource_info"),
                                               dataTableOutput(outputId="data_resource_table"))))
                                ) 
                            )),
                   tabPanel("Visualizations",
                            fluidRow(
                              titlePanel("Berlin Open Data, Visualized"),
                              tabsetPanel(
                                id="tab",
                                tabPanel("Datasets",
                                         column(
                                           2,
                                           wellPanel(
                                             selectInput(
                                               "datasets_x",
                                               "Select variable",
                                               choices=c("creator", "pub_date", "pub_date_filtered"),
                                               selected="creator"
                                             ) ,
                                             submitButton("Plot")
                                           )),
                                         column(
                                           10,
                                           mainPanel(
                                             conditionalPanel(
                                               "!$('#datasets_plot img').length",
                                               p("Downloading info for all datasets...")
                                             ),
                                             verbatimTextOutput(outputId="datasets_plot_info"),
                                             plotOutput("datasets_plot")
                                           ))),
                                tabPanel("Data Resources",
                                         column(
                                           2,
                                           wellPanel(
                                             selectInput(
                                               "data_resources_x",
                                               "Select variable",
                                               choices=c("format", "language", "scheme"),
                                               selected="format"
                                             ) ,
                                             submitButton("Plot")
                                           )),
                                         column(
                                           10,
                                           mainPanel(
                                             conditionalPanel(
                                               "!$('#data_resources_plot img').length",
                                               p("Downloading info for all data resources..."), 
                                               p("This can take some time, please be patient!")
                                             ),
                                             verbatimTextOutput(outputId="data_resources_plot_info"),
                                             plotOutput("data_resources_plot")
                                           )
                                           ))
                              )
                            )
                   )
))
