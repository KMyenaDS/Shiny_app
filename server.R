
# Server principal

server <- function(input, output, session){
  # modules
  up <- uploadServer("up1")
  data_reactive <- reactive({
    req(up$data())
    df <- up$data()
    # convert small character columns to factor (optionnel)
    df[] <- lapply(df, function(col){
      if (is.character(col) && length(unique(col)) / length(col) < 0.5 && length(unique(col)) < 50) as.factor(col) else col
    })
    df
  })
  
  vars <- varselectServer("vs1", data_reactive)
  descServer("desc1", data_reactive)
  modelServer("mod1", data_reactive)
  
  output$data_preview <- renderDT({
    req(data_reactive())
    datatable(head(data_reactive(), 200))
  })
  
  output$download_data <- downloadHandler(
    filename = function() paste0("data_", Sys.Date(), ".csv"),
    content = function(file) {
      req(data_reactive())
      write.csv(data_reactive(), file, row.names = FALSE)
    }
  )
}
