
# UI principal

dashboardHeaderTag <- dashboardHeader(
  title = tagList(
    img(src = "Logo_CIC-P_2018-HD_2.png", height = "30px"),
    "CDC's dashboad analysis"
  )
)

dashboardSidebarTag <- dashboardSidebar(
  sidebarMenu(
    menuItem("Importer", tabName = "import", icon = icon("upload")),
    menuItem("Variables", tabName = "vars", icon = icon("list")),
    menuItem("Données", tabName = "data", icon = icon("table")),
    menuItem("Description", tabName = "desc", icon = icon("chart-bar")),
    menuItem("Modélisation", tabName = "model", icon = icon("project-diagram")),
    menuItem("Aide", tabName = "help", icon = icon("question-circle"))
  )
)

dashboardBodyTag <- dashboardBody(
  tabItems(
    tabItem(tabName = "import",
            fluidRow(box(width = 12, title = "Importer / Préparer", uploadUI("up1")))),
    tabItem(tabName = "vars",
            fluidRow(box(width = 12, title = "Variables disponibles", varselectUI("vs1")))),
    tabItem(tabName = "data",
            fluidRow(box(width = 12, title = "Prévisualisation des données", DTOutput("data_preview") %>% withSpinner()))),
    tabItem(tabName = "desc",
            fluidRow(box(width = 12, title = "Analyse descriptive", descUI("desc1")))),
    tabItem(tabName = "model",
            fluidRow(box(width = 12, title = "Modélisation", modelUI("mod1")))),
    tabItem(tabName = "help",
            fluidRow(box(width = 12, title = "Documentation & Aide",
                         p("Cette application permet de :"),
                         tags$ul(
                           tags$li("Charger un jeu de données (csv / xlsx / rds)"),
                           tags$li("Visualiser les données"),
                           tags$li("Analyser descriptivement (univarié / multivarié)"),
                           tags$li("Modéliser (uni / multivarié)"),
                           tags$li("Télécharger")
                         )
            )))
  ),
  fluidRow(
    box(width = 12, title = "Exporter", solidHeader = TRUE, downloadButton("download_data", "Télécharger"), style = "text-align:center;")
  )
)

ui <- dashboardPage(dashboardHeaderTag, dashboardSidebarTag, dashboardBodyTag)
