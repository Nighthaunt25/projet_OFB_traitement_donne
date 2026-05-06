library(shiny)
library(leaflet)
library(plotly)

ui <- fluidPage(
  titlePanel("Hydrologiques"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput("dept", "Choisir un département :",
                  choices = setNames(sprintf("%02d", 1:95), sprintf("Département %02d", 1:95)),
                  selected = "1"),
      
      helpText("Analyse basée sur le Q90 et le VCN10."),
      actionButton("run_all", "Lancer la recherche départementale", class = "btn-primary")
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Carte des Stations", leafletOutput("map_france")),
        tabPanel("Q90", plotlyOutput("graph_q90"),),
        tabPanel("VCN10", plotlyOutput("graph_vcn10"),)
      )
    )
    
  

  )
)