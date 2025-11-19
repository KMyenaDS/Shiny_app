
# Description module UI + Server

descUI <- function(id){
  ns <- NS(id)
  tagList(
    radioButtons(ns("mode"), "Mode descriptif", choices = c("Univarié" = "uni", "Multivarié" = "multi"), inline = TRUE),
    conditionalPanel(
      condition = paste0("input['", ns("mode"), "'] == 'uni'"),
      pickerInput(ns("vars_uni"), "Variables à décrire", choices = NULL, multiple = TRUE, options = list(`live-search` = TRUE)),
      radioButtons(ns("display_uni"), "Afficher sous forme", choices = c("Table" = "table", "Graphique" = "graph"))
    ),
    conditionalPanel(
      condition = paste0("input['", ns("mode"), "'] == 'multi'"),
      pickerInput(ns("vars_multi"), "Variables à décrire", choices = NULL, multiple = TRUE, options = list(`live-search` = TRUE)),
      pickerInput(ns("by_var"), "Grouper par", choices = NULL, options = list(`live-search` = TRUE))
    ),
    actionButton(ns("run_desc"), "Lancer descriptif"),
    hr(),
    uiOutput(ns("desc_output"))
  )
}

descServer <- function(id, data){
  moduleServer(id, function(input, output, session){
    # update choices when data changes
    observe({
      req(data())
      updatePickerInput(session, "vars_uni", choices = names(data()))
      updatePickerInput(session, "vars_multi", choices = names(data()))
      updatePickerInput(session, "by_var", choices = c("(Aucun)" = "", names(data())))
    })
    
    output$desc_output <- renderUI({
      req(input$run_desc)
      isolate({
        if (input$mode == "uni") {
          req(input$vars_uni)
          if (input$display_uni == "table") {
            gt_output(NS(id, "tbl_desc"))
          } else {
            plotOutput(NS(id, "plot_desc"))
          }
        } else {
          req(input$vars_multi)
          gt_output(NS(id, "tbl_desc"))
        }
      })
    })
    
    output$tbl_desc <- render_gt({
      req(data())
      if (input$mode == "uni" && input$display_uni == "table") {
        tbl_summary(data()[, input$vars_uni, drop = FALSE]) %>% as_gt()
      } else if (input$mode == "multi") {
        by_var <- if (isTruthy(input$by_var) && input$by_var != "") input$by_var else NULL
        df_to_use <- data()[, unique(c(input$vars_multi, by_var)), drop = FALSE]
        tbl_summary(df_to_use, by = by_var) %>% as_gt()
      } else {
        # nothing
        NULL
      }
    })
    
    output$plot_desc <- renderPlot({
      req(data(), input$vars_uni, input$display_uni == "graph")
      vars <- input$vars_uni
      n <- length(vars)
      if (n == 0) return(NULL)
      cols <- ceiling(sqrt(n))
      rows <- ceiling(n / cols)
      par(mfrow = c(rows, cols))
      for (v in vars) {
        colv <- data()[[v]]
        if (is.numeric(colv)) {
          hist(colv, main = v)
        } else {
          pie(table(colv), main = v)
        }
      }
      par(mfrow = c(1,1))
    })
  })
}
