# Bike Rental Data Analysis Shiny App

This repository contains a Shiny application for visualizing and analyzing bike rental data. The data is sourced from Kaggle and includes various attributes such as date, temperature, humidity, and count of bike rentals. The application provides interactive plots to explore the data and understand patterns.

## Table of Contents
1. [Introduction](#introduction)
2. [Data Source](#data-source)
3. [Attribute Information](#attribute-information)
4. [Installation](#installation)
5. [Usage](#usage)
6. [Features](#features)
7. [Conclusion](#conclusion)
8. [License](#license)

## Introduction

This Shiny app allows users to explore and visualize bike rental data. It includes various plots such as histograms, box plots, scatter plots, and time series plots to analyze the data based on different attributes and filters.

## Data Source

The data used in this app is sourced from Kaggle. It includes rental data for bikes with various attributes. You can find the dataset [here](https://www.kaggle.com/).

## Attribute Information

The dataset contains the following attributes:

1. **dteday**: Date of the rental
2. **season**: Season (1: Winter, 2: Spring, 3: Summer, 4: Fall)
3. **yr**: Year (0: 2011, 1: 2012)
4. **mnth**: Month (1 to 12)
5. **holiday**: Whether the day is a holiday (0: No, 1: Yes)
6. **weekday**: Day of the week (0: Sunday, 1: Monday, ..., 6: Saturday)
7. **workingday**: Whether the day is a working day (0: No, 1: Yes)
8. **weathersit**: Weather situation (1: Clear, 2: Mist + Cloudy, 3: Light Snow + Rain, 4: Heavy Rain + Thunderstorm)
9. **temp**: Normalized temperature in Celsius
10. **atemp**: Normalized feeling temperature in Celsius
11. **hum**: Normalized humidity
12. **windspeed**: Normalized wind speed
13. **cnt**: Count of total bike rentals

## Installation

To run the Shiny app, you need to have R and Shiny installed on your machine. Install the required packages using the following commands:

```r
install.packages("shiny")
install.packages("plotly")
install.packages("dplyr")
install.packages("ggplot2")
install.packages("readr")
```

## Usage

1. Clone this repository to your local machine.
2. Open the R script containing the Shiny app code.
3. Run the script in RStudio or any other R environment.
4. The Shiny app will launch in your default web browser.

## Features

### Interactive Plots

1. **Histogram**: Displays the distribution of total bike rentals.
2. **Box Plot**: Shows the count of bike rentals by weekday and working day.
3. **Scatter Plot 1**: Visualizes the count of bike rentals by temperature and humidity.
4. **Scatter Plot 2**: Visualizes the count of bike rentals by wind speed and humidity.
5. **Time Series Plot**: Displays the count of bike rentals over time.

### Filters

- **Date Range**: Select the date range to filter the data.
- **Season**: Filter the data by season.
- **Holiday**: Filter the data by holiday status.
- **Weather Situation**: Filter the data by weather situation.

### Server Code

The server code defines the reactive functions and renders the plots based on the filtered data.

```r
server <- function(input, output) {
  # Reactive function to filter data based on the date range input and selected filters
  filtered_data <- reactive({
    bike_rental %>%
      filter(dteday >= input$date_range[1] & dteday <= input$date_range[2]) %>%
      mutate(weekday = factor(weekday, levels = 0:6, labels = c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday")),
             workingday = factor(workingday, levels = c(0, 1), labels = c("Non-Working Day", "Working Day")))
  })
  
  # Plot 1: Histogram
  output$histogram <- renderPlotly({
    ggplot(filtered_data(), aes(x = cnt)) +
      geom_histogram(binwidth = 100, fill = "darkblue", color = "white") +
      xlab("Count of Total Rental Bikes") +
      ylab("Frequency") +
      ggtitle("Distribution of Total Number of Bike Rentals") +
      theme(plot.title = element_text(family = "Times New Roman", size = 12))
  })
  
  # Plot 2: Boxplot
  output$boxplot <- renderPlotly({
    ggplot(filtered_data(), aes(x = weekday, y = cnt, fill = workingday)) +
      geom_boxplot(position = "identity", alpha = 0.7) +
      scale_fill_manual(values = c("Non-Working Day" = "darkblue", "Working Day" = "orange")) +
      xlab("Weekday") +
      ylab("Count of Bike Rentals") +
      ggtitle("Count of Bike Rentals by Weekday and Working Day") +
      theme(text = element_text(family = "Times New Roman"))
  })
  
  # Plot 3: Scatter Plot 1
  output$scatter1 <- renderPlotly({
    ggplot(filtered_data(), aes(x = temp, y = cnt)) +
      geom_point(aes(color = hum)) +
      scale_color_gradient(low = "darkblue", high = "red", name = "Humidity") +
      geom_smooth(method = "lm", se = TRUE, level = 0.95) +
      xlab("Temperature") +
      ylab("Count of Bike Rentals") +
      ggtitle("Count of Bike Rentals by Temperature and Humidity") +
      theme(text = element_text(family = "Times New Roman"))
  })
  
  # Plot 4: Scatter Plot 2
  output$scatter2 <- renderPlotly({
    ggplot(filtered_data(), aes(x = windspeed, y = cnt)) +
      geom_point(aes(color = hum)) +
      scale_color_gradient(low = "darkblue", high = "red", name = "Humidity") +
      geom_smooth(method = "lm", se = TRUE, level = 0.95) +
      xlab("Wind Speed") +
      ylab("Count of Bike Rentals") +
      ggtitle("Count of Bike Rentals by Wind Speed and Humidity") +
      theme(text = element_text(family = "Times New Roman"))
  })
  
  # Plot 5: Time Series Plot
  output$time_series <- renderPlotly({
    filtered_data() %>%
      mutate(dteday = as.Date(dteday)) %>%
      plot_ly(x = ~dteday, y = ~cnt, type = "scatter", mode = "lines", line = list(color = "darkblue")) %>%
      layout(title = "Count of Bike Rentals over Time",
             xaxis = list(title = "Date", tickfont = list(family = "Times New Roman")),
             yaxis = list(title = "Count of Bike Rentals", tickfont = list(family = "Times New Roman")),
             font = list(family = "Times New Roman"),
             showlegend = FALSE,  # Hide legend to preserve the formatting
             margin = list(l = 50, r = 20, t = 50, b = 70))  # Adjust margins for better appearance
  })
}
```

### UI Code

The UI code defines the layout and components of the Shiny app.

```r
ui <- fluidPage(
  # Custom CSS style to center the title
  tags$style(HTML("
    .title-panel {
      margin-top: 0px;
      margin-bottom: 0px;
      color: #FFFFFF; /* Set the font color to white (#FFFFFF) */
      background-color: #00008B; /* Set the background color to Darkblue (#00008B) */
      width: 100%; /* Extend the width to cover the entire container */
      height: 80px; /* Set a specific height for the title panel (adjust as needed) */
    }
    .title-panel .title {
      font-family: 'Times New Roman', Times, serif;
      font-size: 60px;
      font-weight: bold;
      text-align: center; /* Align the content (title) to the center */
      margin-bottom: 0px; /* Add some spacing between the title and subtitle */
    }
    .title-panel .subtitle {
      font-family: 'Times New Roman', Times, serif;
      font-size: 15px;
      font-weight: bold;
      text-align: center; /* Align the content (subtitle) to the left */
      margin-top: 0;
      padding-left: 10px; /* Add some padding on the left side for spacing */
    }
  ")),
  
  # UI components
  titlePanel(
    div(class = "title-panel",
        div(class = "title", "DataSon Analytics Dashboard"),
        div(class = "subtitle", "Data Son of Data")
    )),
  
  sidebarLayout(
    sidebarPanel(dateRangeInput("date_range", "Select Date Range:",
                                start = min(bike_rental$dteday),
                                end = max(bike_rental$dteday),
                                min = min(bike

_rental$dteday),
                                max = max(bike_rental$dteday)),
                 
                 # Select Input for Seasons
                 selectInput("season_filter", "Select Season:",
                             choices = c("Spring", "Summer", "Fall", "Winter"),
                             multiple = TRUE),
                 
                 # Select Input for Holiday
                 selectInput("holiday_filter", "Select Holiday:",
                             choices = c("No Holiday", "Holiday"),
                             multiple = TRUE),
                 
                 # Select Input for Weather Situation
                 selectInput("weathersit_filter", "Select Weather Situation:",
                             choices = c("Clear", "Mist + Cloudy", "Light Snow + Rain", "Heavy Rain + Thunderstorm"),
                             multiple = TRUE)
    ),
    mainPanel(
      # Interactive histogram using plotly
      plotlyOutput("histogram"),
      
      # Interactive box plot using plotly
      plotlyOutput("boxplot"),
      
      # Interactive scatter plot 1 using plotly
      plotlyOutput("scatter1"),
      
      # Interactive scatter plot 2 using plotly
      plotlyOutput("scatter2"),
      
      # Interactive time series plot using plotly
      plotlyOutput("time_series")
    )
  ))

# Run the application
shinyApp(ui, server)
```

## Conclusion

This Shiny app provides an interactive way to explore bike rental data, allowing users to visualize and analyze patterns and trends. The app includes various plots and filters to facilitate data analysis.

