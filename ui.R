library(shiny)

shinyUI(
  fluidPage(
    sidebarLayout(
      sidebarPanel(
        fileInput("file", "Choose CSV File",
                  accept = c(
                    "text/csv",
                    "text/comma-separated-values,text/plain",
                    ".csv")
        ),
        tags$hr(),
        
        sliderInput("period", "Period", min = 1, max = 30, value = 3)
        
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