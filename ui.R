library(shiny)

shinyUI(
  fluidPage(
    sidebarLayout(
      sidebarPanel(
        fileInput("file", "Choose csv file",
                  accept = c(
                    "text/csv",
                    "text/comma-separated-values,text/plain",
                    ".csv")
        ),
        tags$hr(),
        numericInput("lag.max", "The highest lag order", value = 12),
        
        tags$hr(),
        numericInput("period", "Period", value = 3)
        
      ),
      mainPanel(
        tabsetPanel(type = "tabs",
                    tabPanel("Data", tableOutput("data")),
                    tabPanel("Predict", tableOutput("pred_data")),
                    tabPanel("Plot", 
                             htmlOutput("trend_name"),
                             plotOutput("plot")),
                    tabPanel("Summary", verbatimTextOutput("sum"))
        )
      )
    )
  )
)