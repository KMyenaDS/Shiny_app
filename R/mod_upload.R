
# --- Upload file
# Upload module UI + Server

uploadUI <- function(id){
  ns <- NS(id)
  tagList(
    fileInput(ns("file"), "Importer un fichier (csv / xlsx / rds)", accept = c('.csv', '.xlsx', '.rds')),
    radioButtons(ns("sep"), "Séparateur (CSV)", choices = c("," = ",", ";" = ";", "tab" = "\t"), selected = ","),
    checkboxInput(ns("header"), "Header (CSV)", TRUE)
  )
}

uploadServer <- function(id){
  moduleServer(id, function(input, output, session){
    data <- reactive({
      req(input$file)
      ext <- tools::file_ext(input$file$name)
      if (ext == "csv") {
        read.csv(input$file$datapath, sep = input$sep, header = input$header, stringsAsFactors = FALSE)
      } else if (ext %in% c("xls","xlsx")) {
        readxl::read_excel(input$file$datapath)
      } else if (ext == "rds") {
        readRDS(input$file$datapath)
      } else {
        validate("Type de fichier non supporté")
      }
    })
    return(list(data = data))
  })
}
