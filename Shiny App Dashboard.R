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
    filtered_data <- filtered_data()
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
    filtered_data <- filtered_data()
    filtered_data %>%
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
                                min = min(bike_rental$dteday),
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
