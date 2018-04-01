
source("ezvar.R")

server <- function(input, output, session) {
  observeEvent(input$file, {
    
    csv_file <- reactive({read.csv(input$file$datapath)})
    output$data <- renderTable({csv_file()})
    
    result <- reactive({var.aic(csv_file())})
    pred <- reactive({var.pred(result(), n.ahead = input$period)})
    
    output$trend_name <- renderUI({
      selectInput("trend_name", "Name", as.vector(names(pred())))

    })

    output$pred_data <- renderTable({pred()})
    output$sum <- renderPrint({summary(result())})
    output$plot <- renderPlot({plot.trend(data =csv_file(), pred = pred(), name = input$trend_name)})
  })
}