library(shiny)
library(leaflet)
library(plotly)
library(DT)

addResourcePath("static", "assets/css")
addResourcePath("img", "assets/image")

ui <- fluidPage(

  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "static/style.css"),
    tags$link(rel = "icon", type = "image/png", href = "img/favicon.png")
  ),

  div(
    class = "header-bar",
    h1(class = "TitreAppli", "HydroTrends — Analyse des milieux aquatiques")
  ),

  tags$img(
    src   = "img/logo.png",
    alt   = "Logo OFB",
    style = "position:fixed; bottom:0; right:0; padding:10px; z-index:100; width:180px;"
  ),

  tags$img(
    src   = "img/filigrane.png",
    alt   = "filigrane",
    style = "position:fixed; bottom:0; right:0; padding:0; width:700px; z-index:-1; opacity:0.9;"
  ),

  sidebarLayout(

    sidebarPanel(
      width = 2,
      h2("Panneau de sélection"),

      selectInput("dept", "Département :",
        choices  = setNames(sprintf("%02d", 1:95), sprintf("Département %02d", 1:95)),
        selected = "02"
      ),

      helpText("Analyse hydrologique basée sur le Q90, Q50, VCN10 et VCN3."),

      actionButton("run_all", "Lancer la recherche", class = "btn-primary"),
      
      br(), hr(), # Espace de séparation avant les définitions
      
      h3("Lexique & Définitions", style = "margin-top: 15px; font-size: 1.1em; font-weight: bold; color: #2c3e50;"),
      
      # Accordéons en HTML natif (Details / Summary) pour éviter l'erreur de fonction manquante
      tags$style(HTML("
        details { margin-bottom: 8px; padding: 5px; background: #fafafa; border-radius: 4px; border: 1px solid #e0e0e0; }
        summary { font-weight: bold; cursor: pointer; color: #337ab7; outline: none; }
        summary:hover { color: #23527c; }
        details[open] summary { margin-bottom: 5px; border-bottom: 1px solid #ddd; padding-bottom: 3px; }
      ")),

      tags$details(
        tags$summary("VCN10"),
        p("Le ", strong("VCN10"), " est un indicateur hydrologique qui représente le plus faible débit moyen calculé sur une période glissante de 10 jours consécutifs au cours d’une année. Il est utilisé pour caractériser l’intensité des périodes d’étiage, lorsque les débits des cours d’eau sont les plus faibles. En moyennant les débits sur 10 jours, il permet de lisser les variations journalières et de mieux représenter les situations durables de basses eaux. Le VCN10 est fréquemment employé dans les études hydrologiques, la gestion de la ressource en eau et l’évaluation de l’impact des sécheresses sur les milieux aquatiques. Cet indicateur constitue ainsi une référence importante pour l’analyse du fonctionnement des cours d’eau en période sèche.", style = "font-size: 0.9em; text-align: justify;")
      ),
      
      tags$details(
        tags$summary("VCN3"),
        p("Le ", strong("VCN3"), " est un indicateur hydrologique qui représente le plus faible débit moyen calculé sur une période glissante de 3 jours consécutifs au cours d’une année. Le VCN3 est particulièrement utilisé pour suivre les situations de sécheresse hydrologique et évaluer la vulnérabilité des cours d’eau en période de basses eaux. Plus sa valeur est faible, plus l’étiage est sévère. Cet indicateur est souvent employé pour la gestion quantitative de la ressource en eau et la définition des seuils d’alerte sécheresse.", style = "font-size: 0.9em; text-align: justify;")
      ),
      
      tags$details(
        tags$summary("Q90"),
        p("Le ", strong("Q90"), " est le débit associé à une fréquence de dépassement de 90 %, obtenu à partir de la courbe des débits classés. Il correspond à un quantile de basses eaux caractérisant les écoulements faibles mais récurrents d’un cours d’eau. Cet indicateur est largement utilisé pour l’analyse des étiages, la gestion quantitative de la ressource en eau et la définition des seuils de sécheresse hydrologique.", style = "font-size: 0.9em; text-align: justify;")
      ),
      
      tags$details(
        tags$summary("Q50"),
        p("Le ", strong("Q50"), ", ou débit médian, est le débit dépassé 50 % du temps sur une période de référence. Il représente le débit « typique » d’un cours d’eau et permet de caractériser les conditions hydrologiques habituelles en étant peu influencé par les crues ou les étiages exceptionnels.", style = "font-size: 0.9em; text-align: justify;")
      ),
      
      tags$details(
        tags$summary("Courbe des débits classés"),
        p("La ", strong("courbe des débits classés"), " est une représentation statistique qui classe l’ensemble des débits observés d’un cours d’eau du plus élevé au plus faible et les associe à leur fréquence de dépassement. Elle permet de caractériser le régime hydrologique d’un cours d’eau et de déterminer des indicateurs tels que le Q90, le Q50 ou le Q10, utilisés pour l’analyse des basses et hautes eaux.", style = "font-size: 0.9em; text-align: justify;")
      ),
      
      tags$details(
        tags$summary("Durée de sécheresse (Q90)"),
        p("La ", strong("durée de sécheresse"), " est définie dans cette étude comme le nombre de jours par an pendant lesquels le débit journalier est inférieur au seuil de référence Q90, correspondant au débit dépassé 90 % du temps. Ce seuil, issu de la courbe des débits classés, est largement utilisé en hydrologie pour caractériser les basses eaux et le régime d’étiage des cours d’eau. Cet indicateur permet de quantifier la persistance des épisodes de faible débit et d’analyser leur évolution temporelle. Une durée de sécheresse élevée traduit des périodes plus fréquentes et plus longues de déficit hydrologique.", style = "font-size: 0.9em; text-align: justify;")
      ),
      
      tags$details(
        tags$summary("Tendance hydrologique"),
        p("Une ", strong("tendance"), " désigne l’évolution à long terme d’un indicator hydrologique au cours du temps. Elle peut être croissante, décroissante ou nulle et permet d’identifier d’éventuelles modifications durables des conditions hydrologiques. Dans cette étude, les tendances sont analysées à l’aide du test de Mann-Kendall et de l’estimateur de Sen-Theil appliqués aux indicateurs de durée de sécheresse et de VCN10.", style = "font-size: 0.9em; text-align: justify;")
      )
    ),

    mainPanel(
      width = 10,

      tabsetPanel(id = "tabs",

        tabPanel("Carte des stations",
          br(),
          leafletOutput("map_france", height = "500px")
        ),

        tabPanel("Q90 / Q50",
          br(),
          DTOutput("q90")
        ),

        tabPanel("VCN10 / VCN3",
          br(),
          plotlyOutput("vcn", height = "400px"),
          hr(),
          DTOutput("vcn_tableau")
        ),

        tabPanel("Tendances de sécheresse",
          br(),
          leafletOutput("carte_tend_q90", height = "400px"),
          hr(),
          DTOutput("tendances_q90")
        ),

        tabPanel("Tendances VCN",
          br(),
          leafletOutput("carte_tendvcn", height = "400px"),
          hr(),
          DTOutput("tendvcn")
        )

      )
    )
  )
)