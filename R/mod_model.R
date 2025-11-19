
# Modelling module UI + Server

modelUI <- function(id){
  ns <- NS(id)
  tagList(
    radioButtons(ns("mode"), "Mode Modélisation", choices = c("Univarié" = "uni", "Multivarié" = "multi"), inline = TRUE),
    conditionalPanel(
      condition = paste0("input['", ns("mode"), "'] == 'uni'"),
      selectInput(ns("y_uni"), "Variable dépendante (Y)", choices = NULL),
      selectInput(ns("x_uni"), "Variable explicative (X)", choices = NULL)
    ),
    conditionalPanel(
      condition = paste0("input['", ns("mode"), "'] == 'multi'"),
      selectInput(ns("y_multi"), "Variable dépendante (Y)", choices = NULL),
      pickerInput(ns("x_multi"), "Variables explicatives (X)", choices = NULL, multiple = TRUE),
      checkboxInput(ns("stepwise"), "Sélection pas à pas (stepwise)", FALSE)
    ),
    actionButton(ns("run_model"), "Lancer modèle"),
    hr(),
    verbatimTextOutput(ns("model_output")),
    gt_output(ns("model_tbl"))
  )
}

modelServer <- function(id, data){
  moduleServer(id, function(input, output, session){
    observe({
      req(data())
      updateSelectInput(session, "y_uni", choices = names(data()))
      updateSelectInput(session, "x_uni", choices = names(data()))
      updateSelectInput(session, "y_multi", choices = names(data()))
      updatePickerInput(session, "x_multi", choices = names(data()))
    })
    
    fit_res <- eventReactive(input$run_model, {
      req(data())
      df <- data()
      if (input$mode == "uni") {
        req(input$y_uni, input$x_uni)
        f <- as.formula(paste(input$y_uni, "~", input$x_uni))
        fam <- choose_model_family(df[[input$y_uni]])
        fit <- fit_model(df, f, fam)
        list(mode = "uni", fit = fit, family = fam)
      } else {
        req(input$y_multi, input$x_multi)
        f <- as.formula(paste(input$y_multi, "~", paste(input$x_multi, collapse = "+")))
        fam <- choose_model_family(df[[input$y_multi]])
        fit <- fit_model(df, f, fam)
        if (isTRUE(input$stepwise)) {
          # ensure step receives a fitted model
          fit <- tryCatch({ step(fit, direction = "both", trace = 0) }, error = function(e) fit)
        }
        list(mode = "multi", fit = fit, family = fam)
      }
    })
    
    output$model_output <- renderPrint({
      res <- fit_res()
      req(res)
      print(broom::tidy(res$fit))
    })
    
    output$model_tbl <- render_gt({
      res <- fit_res()
      req(res)
      tbl_regression(res$fit, exponentiate = (res$family == "binomial")) %>% as_gt()
    })
  })
}
