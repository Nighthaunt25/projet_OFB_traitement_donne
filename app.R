library(shiny)

# 1. Charger l'interface
source("ui.R") 

# 2. Charger la fonction serveur depuis ton sous-dossier
# Cela va créer un objet nommé 'server' dans ta mémoire R
source("assets/function/server.R") 

# 3. Lancer l'app en utilisant les objets chargés
shinyApp(ui = ui, server = server)