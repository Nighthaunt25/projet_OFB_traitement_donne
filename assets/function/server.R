# lancer le code shiny::runApp()

library(shiny)
library(httr2)
library(plotly)
library(ggplot2)
library(dplyr)
library(leaflet)

server <- function(input, output) {
  
  stations_dept <- eventReactive(input$run_all, {
    req <- request("https://hubeau.eaufrance.fr/api/v2/hydrometrie/referentiel/stations") %>%
      req_url_query(code_departement = input$dept, en_service = TRUE, format = "json")
    
    tryCatch({
      resp <- req %>% req_perform()
      return(resp_body_json(resp, simplifyVector = TRUE)$data)
    }, error = function(e) return(NULL))
  })


  station_value <- function(station_nb){
    req <- request("https://hubeau.eaufrance.fr/api/v2/hydrometrie/obs_elab") %>%
      req_url_query(code_station = station_nb, format = "json")
    tryCatch({
      resp <- req %>% req_perform()
      return(resp_body_json(resp, simplifyVector = TRUE)$data)
    }, error = function(e) return(NULL))
  }


output$map_france <- renderLeaflet({
  data <- stations_dept()
  
  m <- leaflet() %>% addTiles()
  
  if (!is.null(data) && nrow(data) > 0) {
    m <- m %>% addCircleMarkers(
      lng = as.numeric(data$longitude_station), 
      lat = as.numeric(data$latitude_station),
      radius = 5, 
      if ( 1==1 ) {
         color = "blue", 
      }
      fillOpacity = 0.7,
      popup = paste("Station :", data$libelle_station)
    )
  }
  
  m
})
# 

  # output$graph_q90 <- renderPlotly({,
  # })

  output$graph_vcn10 <- renderPlotly({

  df <- stations_dept()
  req(df) 
  
  p <- ggplot(df, aes(x = date_obs_elab, y = resultat_obs_elab)) +
    geom_line(color = "steelblue") +
    geom_point() +
    geom_smooth(method = "lm", color = "red") +
    theme_minimal()
  
  ggplotly(p)
})
}