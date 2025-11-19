
# Variable selection module

varselectUI <- function(id){
  ns <- NS(id)
  uiOutput(ns("vars_ui"))
}

varselectServer <- function(id, data){
  moduleServer(id, function(input, output, session){
    output$vars_ui <- renderUI({
      req(data())
      pickerInput(session$ns("vars"), "Variables disponibles", choices = names(data()), multiple = TRUE, options = list(`live-search` = TRUE))
    })
    return(reactive({ input$vars }))
  })
}