library(shiny)

# charger l'interface
source("ui.R") 

# cela va créer un objet nommé 'server' dans la mémoire R
source("assets/function/server.R") 

# lancer l'app en utilisant les objets chargés
shinyApp(ui = ui, server = server)