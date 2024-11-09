# server.R
library(shiny)
library(leaflet)
library(jsonlite)
library(plotly)

# Function to get current weather information from OpenWeatherMap
get_weather_info <- function(lat, lon) {
  api_key <- "*******************************" #your api
  API_call <- "https://api.openweathermap.org/data/2.5/weather?lat=%s&lon=%s&appid=%s"
  complete_url <- sprintf(API_call, lat, lon, api_key)
  json <- fromJSON(complete_url)
  
  if (is.null(json$name)) {
    return(NULL)  # Return NULL if location info not found
  }
  
  location <- json$name
  temp <- json$main$temp - 273.2
  feels_like <- json$main$feels_like - 273.2
  humidity <- json$main$humidity
  weather_condition <- json$weather$description
  visibility <- json$visibility
  wind_speed <- json$wind$speed
  
  list(
    Location = location,
    Temperature = temp,
    Feels_like = feels_like,
    Humidity = humidity,
    WeatherCondition = weather_condition,
    Visibility = visibility,
    Wind_speed = wind_speed
  )
}

# Function to get weather forecast
get_forecast <- function(lat, lon) {
  api_key <- "*****************************" #your api
  API_call <- "https://api.openweathermap.org/data/2.5/forecast?lat=%s&lon=%s&appid=%s"
  complete_url <- sprintf(API_call, lat, lon, api_key)
  json <- fromJSON(complete_url)
  
  if (is.null(json$list)) {
    return(NULL)  # Return NULL if forecast data is unavailable
  }
  
  data.frame(
    Time = json$list$dt_txt,
    Location = json$city$name,
    feels_like = json$list$main$feels_like - 273.2,
    temp_min = json$list$main$temp_min - 273.2,
    temp_max = json$list$main$temp_max - 273.2,
    pressure = json$list$main$pressure,
    sea_level = json$list$main$sea_level,
    grnd_level = json$list$main$grnd_level,
    humidity = json$list$main$humidity,
    temp_kf = json$list$main$temp_kf,
    temp = json$list$main$temp - 273.2,
    id = sapply(json$list$weather, function(entry) entry$id),
    main = sapply(json$list$weather, function(entry) entry$main),
    icon = sapply(json$list$weather, function(entry) entry$icon),
    weather_conditions = sapply(json$list$weather, function(entry) entry$description),
    speed = json$list$wind$speed,
    deg = json$list$wind$deg,
    gust = json$list$wind$gust,
    stringsAsFactors = FALSE
  )
}

# Server
# Server
server <- function(input, output, session) {
  
  # Set default coordinates for Hanoi
  default_lon <- 105.8341598
  default_lat <- 21.0277644
  
  # Fetch weather information for Hanoi on startup
  weather_info <- get_weather_info(default_lat, default_lon)
  
  # Render default weather information for Hanoi
  if (!is.null(weather_info)) {
    output$location <- renderText({ weather_info$Location })
    output$humidity <- renderText({ paste(weather_info$Humidity, "%") })
    output$temperature <- renderText({ paste(weather_info$Temperature, "°C") })
    output$feels_like <- renderText({ paste(weather_info$Feels_like, "°C") })
    output$weather_condition <- renderText({ weather_info$WeatherCondition })
    output$visibility <- renderText({ weather_info$Visibility })
    output$wind_speed <- renderText({ weather_info$Wind_speed })
  }
  
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      setView(lng = default_lon, lat = default_lat, zoom = 10)
  })
  
  click <- NULL
  
  observeEvent(input$map_click, {
    click <<- input$map_click
    weather_info <<- get_weather_info(click$lat, click$lng)
    
    if (is.null(weather_info)) {
      return()  # Stop if weather info is unavailable
    }
    
    output$location <- renderText({ weather_info$Location })
    output$humidity <- renderText({ paste(weather_info$Humidity, "%") })
    output$temperature <- renderText({ paste(weather_info$Temperature, "°C") })
    output$feels_like <- renderText({ paste(weather_info$Feels_like, "°C") })
    output$weather_condition <- renderText({ weather_info$WeatherCondition })
    output$visibility <- renderText({ weather_info$Visibility })
    output$wind_speed <- renderText({ weather_info$Wind_speed })
  })
  
  observeEvent(input$feature, {
    output$location_ <- renderText({ paste('Location: ', weather_info$Location) })
    
    data <- get_forecast(default_lat, default_lon)
    
    if (!is.null(click)) {
      data <- get_forecast(click$lat, click$lng)
    }
    
    if (is.null(data)) {
      output$line_chart <- renderText({"Không có dữ liệu dự báo."})
      return()
    }
    
    if (!(input$feature %in% colnames(data))) {
      output$line_chart <- renderText({"Tính năng không tồn tại trong dữ liệu."})
      return()
    }
    
    output$line_chart <- renderPlotly({
      feature_data <- data[, c("Time", input$feature), drop = FALSE]
      
      plot_ly(data = feature_data, x = ~Time, y = ~.data[[input$feature]], 
              type = 'scatter', mode = 'lines+markers', name = input$feature) %>%
        layout(title = "Sample Line Chart", xaxis = list(title = "Time"), yaxis = list(title = input$feature))
    })
  })
}
