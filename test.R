library(shiny)
library(httr2)
library(plotly)
library(ggplot2)
library(dplyr)
library(leaflet)

stations_dept <- function(){
    req <- request("https://hubeau.eaufrance.fr/api/v2/hydrometrie/referentiel/stations") %>%
      req_url_query(code_departement = "04", en_service = TRUE, format = "json")
    
    tryCatch({
  resp <- req %>% req_perform()
  return(resp_body_json(resp, simplifyVector = TRUE)$data)
}, error = function(e) {
  # C'est ici que tu verras le vrai problème !
  message("Erreur détectée : ", e$message) 
  return(NULL)
})
  }

test <- stations_dept()
print(test)
