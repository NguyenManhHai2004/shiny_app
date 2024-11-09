library(shiny)
library(shinydashboard)
library(leaflet)
library(plotly)

# UI 
ui <- dashboardPage(
  dashboardHeader(
    title = tagList(
      div(
        style = "display: flex; justify-content: center; width: 100%;", 
        tags$span("Shining Weather Dashboard", style = "font-weight: bold; font-size: 20px; margin-right: 20px;")
      )
    )
  ),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Weather", tabName = "weather"),
      menuItem("Forecast", tabName = "forecast")
    )
  ),
  dashboardBody(
    # Inline CSS for styling
    tags$head(
      tags$style(HTML("
        /* Custom background color */
        .content-wrapper, .right-side {
          background-color: #0B2559 !important;
          color: white;
        }
        /* Custom styling */
        .custom-text { 
          font-size: 18px; 
          font-weight: bold; 
          color: white; 
          text-align: center;  /* Center align text */
        }
        .custom-icon, .custom-icon-temp, .box-icon { 
          font-size: 20px; 
          margin-right: 8px; 
          color: white; 
        }
        .custom-text-output1, .custom-text-output2, .custom-text-temp { 
          font-size: 16px; 
          color: white; 
          text-align: center;  /* Center align text */
          font-weight: bold;    /* Bold text */
        }
        .map-container { 
          margin-top: 15px; 
        }
        /* Custom Wind Speed box styling */
        .wind-speed-box {
          background-color: white !important;
          color: black;
          text-align: center;  /* Center align text */
          font-weight: bold;    /* Bold text */
        }
        
      "))),
    tabItems(
      # Weather Tab
      tabItem(
        tabName = "weather",
        fluidRow(
          column(
            width = 6,
            # Centered Location Box
            fluidRow(
              column(
                width = 12, offset = 3,
                box(
                  title = div(tags$i(class = "fas fa-map-marker-alt box-icon"), "Location"),
                  textOutput("location"),  # Output for location
                  background = "purple",
                  class = "wind-speed-box" 
                )
              )
            ),
            # Weather Information Boxes
            fluidRow(  
              box(
                width = 6,
                title = div(tags$i(class = "fas fa-temperature-high box-icon"), "Current Temperature"),
                textOutput("temperature"),
                background = "orange",
                class = "wind-speed-box" 
              ),
              box(
                width = 6,
                title = div(tags$i(class = "fas fa-temperature-high box-icon"), "Feels Like"),
                textOutput("feels_like"),
                background = "red",
                class = "wind-speed-box" 
              ),
              box(
                width = 6,
                title = div(tags$i(class = "fa-solid fa-droplet box-icon"), "Humidity"),
                textOutput("humidity"),
                background = "aqua",
                class = "wind-speed-box" 
              ),
              box(
                width = 6,
                title = div(tags$i(class = "fas fa-smog box-icon"), "Weather Condition"),
                textOutput("weather_condition"),
                background = "olive",
                class = "wind-speed-box" 
              ),
              box(
                width = 6,
                title = div(tags$i(class = "fas fa-eye box-icon"), "Visibility"),
                textOutput("visibility"),
                background = "teal",
                class = "wind-speed-box" 
              ),
              box(
                width = 6,
                title = div(tags$i(class = "fas fa-wind box-icon"), "Wind Speed"),
                textOutput("wind_speed"),
                background = "purple",
                class = "wind-speed-box" # Applying custom CSS class
              )
            )
          ),
          # Map Display
          box(
            width = 5,
            title = 'Location Map',
            leafletOutput("map"),
            status = "primary",
            solidHeader = TRUE,
            class = "map-container"
          )
        )
      ),
      # Forecast Tab
      tabItem(
        tabName = "forecast",
        fluidRow(
          box(
            title = div(tags$i(class = "fas fa-map-marker-alt box-icon"), "Location"),
            textOutput("location_"),  # Output for location
            background = "purple",
            class = "wind-speed-box" 
          ),
          box(
            width = 6,
            title = "Features for Forecast",
            status = "primary",
            solidHeader = TRUE,
            selectInput(
              "feature",
              "Select Feature:",
              choices = list(
                "Temperature" = "temp",
                "Feels Like" = "feels_like",
                "Minimum Temperature" = "temp_min",
                "Maximum Temperature" = "temp_max",
                "Pressure" = "pressure",
                "Sea Level" = "sea_level",
                "Ground Level" = "grnd_level",
                "Humidity" = "humidity",
                "Wind Speed" = "speed",
                "Wind Direction" = "deg",
                "Wind Gust" = "gust"
              )
            )
          )
        ),
        fluidRow(
          box(
            width = 12,
            title = "Forecast Chart",
            status = "primary",
            solidHeader = TRUE,
            plotlyOutput("line_chart")
          )
        )
      )
    )
  )
)

# Server logic will go here