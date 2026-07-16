# =============================================================================
# DataSon Analytics | Capital Bikeshare Intelligence Dashboard
# -----------------------------------------------------------------------------
# A professional, interactive Shiny application for exploring the UCI Capital
# Bikeshare (day.csv) dataset. Designed with a cohesive "Black & Gold Elegance"
# visual identity: bold black, regal gold, deep navy and luminous white, applied
# consistently across every chart through a single shared colour scale rather
# than ad-hoc palettes per plot.
#
# Author : Kibet Philip (Apollop24)
# License: MIT
# =============================================================================

# ---- 1. Packages ------------------------------------------------------------
required_packages <- c(
  "shiny", "bslib", "plotly", "dplyr", "tidyr", "DT",
  "scales", "lubridate"
)

installed <- rownames(installed.packages())
missing_pkgs <- setdiff(required_packages, installed)
if (length(missing_pkgs) > 0) {
  install.packages(missing_pkgs, repos = "https://cloud.r-project.org")
}

library(shiny)
library(bslib)
library(plotly)
library(dplyr)
library(tidyr)
library(DT)
library(scales)
library(lubridate)

# ---- 2. Data ingestion (environment-agnostic) --------------------------------
# The app looks for day.csv relative to its own location, so it runs
# identically in RStudio, Posit Cloud, Docker, or a bare Rscript call.
app_dir  <- tryCatch(dirname(normalizePath(sys.frame(1)$ofile)),
                      error = function(e) getwd())
data_path <- file.path(app_dir, "day.csv")
if (!file.exists(data_path)) data_path <- "day.csv"

bike_raw <- read.csv(data_path, stringsAsFactors = FALSE)

# ---- 3. Data preparation -----------------------------------------------------
season_labels    <- c("1" = "Winter", "2" = "Spring", "3" = "Summer", "4" = "Fall")
weather_labels   <- c("1" = "Clear / Partly Cloudy",
                       "2" = "Mist + Cloudy",
                       "3" = "Light Snow / Rain",
                       "4" = "Heavy Rain / Storm")
weekday_labels   <- c("0" = "Sunday", "1" = "Monday", "2" = "Tuesday",
                       "3" = "Wednesday", "4" = "Thursday", "5" = "Friday",
                       "6" = "Saturday")
month_labels     <- month.abb

bike_rental <- bike_raw %>%
  mutate(
    dteday      = as.Date(dteday),
    year_label  = ifelse(yr == 0, "2011", "2012"),
    season_lbl  = factor(season_labels[as.character(season)],
                          levels = c("Winter", "Spring", "Summer", "Fall")),
    weather_lbl = factor(weather_labels[as.character(weathersit)],
                          levels = weather_labels),
    weekday_lbl = factor(weekday_labels[as.character(weekday)],
                          levels = weekday_labels),
    workingday_lbl = factor(ifelse(workingday == 1, "Working Day", "Non-Working Day"),
                             levels = c("Working Day", "Non-Working Day")),
    holiday_lbl = factor(ifelse(holiday == 1, "Holiday", "No Holiday"),
                          levels = c("No Holiday", "Holiday")),
    month_lbl   = factor(month_labels[mnth], levels = month_labels),
    temp_c      = temp * 41,
    atemp_c     = atemp * 50,
    hum_pct     = hum * 100,
    windspeed_kmh = windspeed * 67
  )

data_min_date <- min(bike_rental$dteday)
data_max_date <- max(bike_rental$dteday)

# ---- 4. Brand palette: "Black & Gold Elegance" -------------------------------
# One shared identity used everywhere -- no clashing rainbow colours.
palette_black_gold <- list(
  black       = "#0B0B0C",
  charcoal    = "#151517",
  panel       = "#111318",
  navy        = "#0A1128",
  navy_deep   = "#050914",
  navy_mid    = "#14213D",
  gold        = "#D4AF37",
  gold_bright = "#F4C430",
  gold_deep   = "#8C6A1F",
  ivory       = "#F5F1E6",
  white       = "#FFFFFF",
  muted       = "#9A9A9E"
)

# Continuous gradient (navy -> gold) used for EVERY continuous colour mapping
# (humidity, windspeed, correlation heatmap, calendar heat, etc.)
gold_continuous <- colorRampPalette(c(
  palette_black_gold$navy_deep,
  palette_black_gold$navy_mid,
  palette_black_gold$gold_deep,
  palette_black_gold$gold,
  palette_black_gold$gold_bright
))

# Categorical shades drawn from the SAME family (gold -> charcoal), so bars,
# boxplots, and lines all read as one coherent design system.
gold_categorical <- c(
  palette_black_gold$gold_bright,
  palette_black_gold$gold,
  palette_black_gold$gold_deep,
  palette_black_gold$navy_mid,
  palette_black_gold$navy,
  palette_black_gold$muted
)

plotly_dark_layout <- function(p, legend_title = NULL) {
  p %>%
    layout(
      paper_bgcolor = palette_black_gold$panel,
      plot_bgcolor  = palette_black_gold$panel,
      font  = list(family = "Georgia, 'Times New Roman', serif",
                   color = palette_black_gold$ivory, size = 13),
      xaxis = list(gridcolor = "#2A2A2E", zerolinecolor = "#2A2A2E",
                   color = palette_black_gold$ivory),
      yaxis = list(gridcolor = "#2A2A2E", zerolinecolor = "#2A2A2E",
                   color = palette_black_gold$ivory),
      legend = list(title = list(text = legend_title),
                    bgcolor = "rgba(0,0,0,0)",
                    font = list(color = palette_black_gold$ivory)),
      margin = list(l = 60, r = 30, t = 60, b = 60)
    ) %>%
    config(displaylogo = FALSE,
           modeBarButtonsToRemove = c("lasso2d", "select2d"))
}

# ---- 5. UI --------------------------------------------------------------------
app_theme <- bs_theme(
  version = 5,
  bg = palette_black_gold$black,
  fg = palette_black_gold$ivory,
  primary = palette_black_gold$gold,
  secondary = palette_black_gold$navy_mid,
  base_font = font_collection("Georgia", "Times New Roman", "serif"),
  heading_font = font_collection("Georgia", "Times New Roman", "serif"),
  code_font = font_collection("Consolas", "Courier New", "monospace")
) %>%
  bs_add_rules("
    body { background-color: #0B0B0C; }
    .navbar { background-color: #0A1128 !important; border-bottom: 2px solid #D4AF37; }
    .navbar-brand, .nav-link { color: #F5F1E6 !important; letter-spacing: 0.5px; }
    .nav-link.active { color: #D4AF37 !important; font-weight: 700; }
    .card, .well, .dataTables_wrapper { background-color: #111318 !important; border: 1px solid #2A2A2E !important; border-radius: 10px; }
    h1, h2, h3, h4 { color: #D4AF37 !important; }
    .kpi-card { background: linear-gradient(145deg, #0A1128, #111318); border: 1px solid #D4AF37; border-radius: 12px; padding: 18px 20px; text-align: center; box-shadow: 0 4px 14px rgba(0,0,0,0.5); }
    .kpi-value { font-size: 30px; font-weight: 700; color: #F4C430; font-family: Georgia, 'Times New Roman', serif; }
    .kpi-label { font-size: 13px; letter-spacing: 1.2px; text-transform: uppercase; color: #9A9A9E; margin-top: 4px; }
    .app-hero { background: linear-gradient(120deg, #0A1128 0%, #151517 60%, #0B0B0C 100%); border-bottom: 3px solid #D4AF37; padding: 28px 24px; margin-bottom: 18px; border-radius: 0 0 14px 14px; }
    .app-hero h1 { font-size: 34px; margin-bottom: 4px; }
    .app-hero p { color: #C9C6BB; font-size: 15px; margin: 0; }
    .form-control, .selectize-input { background-color: #151517 !important; color: #F5F1E6 !important; border: 1px solid #D4AF37 !important; }
    .irs-bar, .irs-bar-edge, .irs-single, .irs-from, .irs-to { background: #D4AF37 !important; border-color: #D4AF37 !important; color: #0B0B0C !important; }
    .btn-primary, .btn-gold { background-color: #D4AF37 !important; border-color: #D4AF37 !important; color: #0B0B0C !important; font-weight: 600; }
    .btn-primary:hover, .btn-gold:hover { background-color: #F4C430 !important; }

    /* ---- Sidebar / filter panel sizing fixes ---- */
    .well { padding: 18px 16px !important; }
    .well h4 { font-size: 19px !important; margin-bottom: 16px !important; letter-spacing: 0.4px; }
    .well .control-label { font-family: Georgia, 'Times New Roman', serif; font-size: 14px !important; font-weight: 600; color: #F5F1E6 !important; margin-bottom: 6px !important; line-height: 1.3; }

    /* Date range: keep both boxes readable, no truncated years */
    .input-daterange.input-group { flex-wrap: nowrap !important; width: 100%; }
    .input-daterange .form-control {
      min-width: 100px !important; width: auto !important; flex: 1 1 100px !important;
      font-size: 13px !important; padding: 5px 6px !important;
    }
    .input-daterange .input-group-addon,
    .input-daterange .input-group-text {
      background: transparent !important; border: none !important;
      color: #9A9A9E !important; padding: 0 6px !important; font-size: 12px !important;
      display: flex; align-items: center;
    }

    /* Multi-select (Season / Weather / Day Type / Holiday): inline chips, not one per line */
    .selectize-control { font-size: 13px !important; }
    .selectize-input {
      display: flex !important; flex-wrap: wrap !important; gap: 4px;
      min-height: 40px; padding: 6px !important; align-items: flex-start;
    }
    .selectize-input > div, .selectize-input .item {
      font-size: 12.5px !important; padding: 3px 8px !important; margin: 0 !important;
      white-space: nowrap; border-radius: 5px;
      background-color: #14213D !important; border: 1px solid #D4AF37 !important;
      color: #F5F1E6 !important;
    }
    .selectize-input input { color: #F5F1E6 !important; font-size: 13px !important; min-width: 40px !important; }
    .selectize-dropdown, .selectize-dropdown-content { background-color: #151517 !important; color: #F5F1E6 !important; font-size: 13px !important; }
    .selectize-dropdown .option { padding: 6px 10px !important; }
    .selectize-dropdown .option.active { background-color: #14213D !important; color: #F4C430 !important; }
    ::-webkit-scrollbar { width: 10px; }
    ::-webkit-scrollbar-track { background: #0B0B0C; }
    ::-webkit-scrollbar-thumb { background: #8C6A1F; border-radius: 6px; }
  ")

kpi_box <- function(value_id, label) {
  div(class = "kpi-card",
      div(class = "kpi-value", textOutput(value_id, inline = TRUE)),
      div(class = "kpi-label", label))
}

sidebar_filters <- sidebarPanel(
  width = 3,
  style = "position: sticky; top: 15px;",
  h4("Filters"),
  dateRangeInput("date_range", "Date Range",
                  start = data_min_date, end = data_max_date,
                  min = data_min_date, max = data_max_date),
  selectInput("season_filter", "Season",
              choices = levels(bike_rental$season_lbl),
              selected = levels(bike_rental$season_lbl),
              multiple = TRUE, selectize = TRUE),
  selectInput("weather_filter", "Weather Situation",
              choices = levels(bike_rental$weather_lbl),
              selected = levels(bike_rental$weather_lbl),
              multiple = TRUE, selectize = TRUE),
  selectInput("workingday_filter", "Day Type",
              choices = levels(bike_rental$workingday_lbl),
              selected = levels(bike_rental$workingday_lbl),
              multiple = TRUE, selectize = TRUE),
  selectInput("holiday_filter", "Holiday Status",
              choices = levels(bike_rental$holiday_lbl),
              selected = levels(bike_rental$holiday_lbl),
              multiple = TRUE, selectize = TRUE),
  hr(style = "border-color:#D4AF37;"),
  downloadButton("download_data", "Download Filtered Data", class = "btn-gold w-100")
)

ui <- tagList(
  tags$head(tags$link(rel = "icon", href = "data:,")),
  page_navbar(
    theme = app_theme,
    title = "DataSon Analytics — Bikeshare Intelligence",
    fillable = FALSE,
    header = div(
      class = "app-hero",
      h1("Capital Bikeshare Intelligence Dashboard"),
      p("A Black & Gold Elegance analytics experience for the UCI Capital Bikeshare dataset (2011\u20132012)")
    ),

    nav_panel("Executive Overview",
      fluidRow(
        column(3, kpi_box("kpi_total", "Total Rentals")),
        column(3, kpi_box("kpi_avg", "Average Daily Rentals")),
        column(3, kpi_box("kpi_registered_share", "Registered Rider Share")),
        column(3, kpi_box("kpi_peak", "Peak Day Volume"))
      ),
      br(),
      fluidRow(
        column(3, sidebar_filters),
        column(9,
          card(full_screen = TRUE,
               card_header("Daily Rental Volume Over Time"),
               plotlyOutput("overview_timeseries", height = "360px")),
          br(),
          fluidRow(
            column(6, card(full_screen = TRUE, card_header("Casual vs. Registered Riders"),
                            plotlyOutput("overview_stacked", height = "320px"))),
            column(6, card(full_screen = TRUE, card_header("Rentals by Season"),
                            plotlyOutput("overview_season", height = "320px")))
          )
        )
      )
    ),

    nav_panel("Distribution",
      fluidRow(
        column(3, sidebar_filters),
        column(9,
          card(full_screen = TRUE, card_header("Distribution of Daily Rental Counts"),
               sliderInput("bin_width", "Histogram Bin Width", min = 50, max = 500,
                           value = 150, step = 25, width = "100%"),
               plotlyOutput("dist_histogram", height = "380px")),
          br(),
          card(full_screen = TRUE, card_header("Rental Count Density by Day Type"),
               plotlyOutput("dist_density", height = "360px"))
        )
      )
    ),

    nav_panel("Seasonality & Weekday",
      fluidRow(
        column(3, sidebar_filters),
        column(9,
          card(full_screen = TRUE, card_header("Rentals by Weekday and Working-Day Status"),
               plotlyOutput("season_boxplot", height = "380px")),
          br(),
          fluidRow(
            column(6, card(full_screen = TRUE, card_header("Monthly Rental Trend"),
                            plotlyOutput("season_month", height = "320px"))),
            column(6, card(full_screen = TRUE, card_header("Rentals by Weather Situation"),
                            plotlyOutput("season_weather", height = "320px")))
          )
        )
      )
    ),

    nav_panel("Weather Impact",
      fluidRow(
        column(3, sidebar_filters),
        column(9,
          card(full_screen = TRUE, card_header("Temperature vs. Rentals (coloured by Humidity)"),
               plotlyOutput("weather_scatter_temp", height = "380px")),
          br(),
          card(full_screen = TRUE, card_header("Wind Speed vs. Rentals (coloured by Humidity)"),
               plotlyOutput("weather_scatter_wind", height = "380px"))
        )
      )
    ),

    nav_panel("Correlation",
      fluidRow(
        column(3, sidebar_filters),
        column(9,
          card(full_screen = TRUE, card_header("Correlation Matrix of Key Variables"),
               plotlyOutput("corr_heatmap", height = "460px"))
        )
      )
    ),

    nav_panel("Data Explorer",
      fluidRow(
        column(3, sidebar_filters),
        column(9,
          card(full_screen = TRUE, card_header("Filtered Dataset"),
               DTOutput("data_table"))
        )
      )
    ),

    nav_spacer(),
    nav_item(tags$span(style = "color:#9A9A9E; font-size:12px; padding-right:10px;",
                        "Data: UCI Capital Bikeshare (Fanaee-T & Gama, 2013)"))
  )
)

# ---- 6. Server ----------------------------------------------------------------
server <- function(input, output, session) {

  filtered_data <- reactive({
    req(input$date_range, input$season_filter, input$weather_filter,
        input$workingday_filter, input$holiday_filter)

    bike_rental %>%
      filter(
        dteday >= input$date_range[1],
        dteday <= input$date_range[2],
        season_lbl %in% input$season_filter,
        weather_lbl %in% input$weather_filter,
        workingday_lbl %in% input$workingday_filter,
        holiday_lbl %in% input$holiday_filter
      )
  })

  # ---- KPI outputs ----
  output$kpi_total <- renderText({
    comma(sum(filtered_data()$cnt))
  })
  output$kpi_avg <- renderText({
    d <- filtered_data()
    if (nrow(d) == 0) return("0")
    comma(round(mean(d$cnt)))
  })
  output$kpi_registered_share <- renderText({
    d <- filtered_data()
    if (nrow(d) == 0 || sum(d$cnt) == 0) return("0%")
    percent(sum(d$registered) / sum(d$cnt), accuracy = 0.1)
  })
  output$kpi_peak <- renderText({
    d <- filtered_data()
    if (nrow(d) == 0) return("0")
    comma(max(d$cnt))
  })

  # ---- Executive Overview ----
  output$overview_timeseries <- renderPlotly({
    d <- filtered_data() %>% arrange(dteday)
    p <- plot_ly(d, x = ~dteday, y = ~cnt, type = "scatter", mode = "lines",
                 line = list(color = palette_black_gold$gold, width = 2),
                 fill = "tozeroy", fillcolor = "rgba(212,175,55,0.15)",
                 hovertemplate = "%{x}<br>Rentals: %{y:,}<extra></extra>") %>%
      layout(xaxis = list(title = "Date"), yaxis = list(title = "Total Rentals"))
    plotly_dark_layout(p)
  })

  output$overview_stacked <- renderPlotly({
    d <- filtered_data() %>% arrange(dteday)
    p <- plot_ly(d, x = ~dteday) %>%
      add_trace(y = ~registered, name = "Registered", type = "scatter", mode = "none",
                stackgroup = "one", fillcolor = palette_black_gold$gold) %>%
      add_trace(y = ~casual, name = "Casual", type = "scatter", mode = "none",
                stackgroup = "one", fillcolor = palette_black_gold$navy_mid) %>%
      layout(xaxis = list(title = "Date"), yaxis = list(title = "Riders"))
    plotly_dark_layout(p, legend_title = "Rider Type")
  })

  output$overview_season <- renderPlotly({
    d <- filtered_data() %>%
      group_by(season_lbl) %>%
      summarise(total = sum(cnt), .groups = "drop")
    p <- plot_ly(d, x = ~season_lbl, y = ~total, type = "bar",
                 marker = list(color = gold_categorical[seq_len(nrow(d))],
                               line = list(color = palette_black_gold$gold_bright, width = 1)),
                 hovertemplate = "%{x}<br>Rentals: %{y:,}<extra></extra>") %>%
      layout(xaxis = list(title = "Season"), yaxis = list(title = "Total Rentals"))
    plotly_dark_layout(p)
  })

  # ---- Distribution ----
  output$dist_histogram <- renderPlotly({
    d <- filtered_data()
    p <- plot_ly(d, x = ~cnt, type = "histogram",
                 xbins = list(size = input$bin_width),
                 marker = list(color = palette_black_gold$gold,
                               line = list(color = palette_black_gold$navy_deep, width = 1))) %>%
      layout(xaxis = list(title = "Count of Total Rentals"), yaxis = list(title = "Frequency"),
             bargap = 0.05)
    plotly_dark_layout(p)
  })

  output$dist_density <- renderPlotly({
    d <- filtered_data()
    p <- plot_ly()
    groups <- levels(d$workingday_lbl)
    cols <- c(palette_black_gold$gold, palette_black_gold$navy_mid)
    for (i in seq_along(groups)) {
      sub <- d %>% filter(workingday_lbl == groups[i])
      if (nrow(sub) > 1) {
        dens <- density(sub$cnt)
        p <- p %>% add_trace(x = dens$x, y = dens$y, type = "scatter", mode = "lines",
                              name = groups[i], line = list(color = cols[i], width = 2),
                              fill = "tozeroy",
                              fillcolor = sprintf("rgba(%s,0.18)",
                                                   paste(grDevices::col2rgb(cols[i]), collapse = ",")))
      }
    }
    p <- p %>% layout(xaxis = list(title = "Count of Total Rentals"), yaxis = list(title = "Density"))
    plotly_dark_layout(p, legend_title = "Day Type")
  })

  # ---- Seasonality & Weekday ----
  output$season_boxplot <- renderPlotly({
    d <- filtered_data()
    p <- plot_ly(d, x = ~weekday_lbl, y = ~cnt, color = ~workingday_lbl,
                 colors = c(palette_black_gold$gold, palette_black_gold$navy_mid),
                 type = "box") %>%
      layout(xaxis = list(title = "Weekday"), yaxis = list(title = "Count of Rentals"),
             boxmode = "group")
    plotly_dark_layout(p, legend_title = "Day Type")
  })

  output$season_month <- renderPlotly({
    d <- filtered_data() %>%
      group_by(month_lbl) %>%
      summarise(total = sum(cnt), .groups = "drop")
    p <- plot_ly(d, x = ~month_lbl, y = ~total, type = "scatter", mode = "lines+markers",
                 line = list(color = palette_black_gold$gold, width = 3),
                 marker = list(color = palette_black_gold$gold_bright, size = 8,
                               line = list(color = palette_black_gold$navy_deep, width = 1))) %>%
      layout(xaxis = list(title = "Month"), yaxis = list(title = "Total Rentals"))
    plotly_dark_layout(p)
  })

  output$season_weather <- renderPlotly({
    d <- filtered_data() %>%
      group_by(weather_lbl) %>%
      summarise(avg = mean(cnt), .groups = "drop")
    p <- plot_ly(d, x = ~weather_lbl, y = ~avg, type = "bar",
                 marker = list(color = gold_categorical[seq_len(nrow(d))])) %>%
      layout(xaxis = list(title = "Weather Situation"), yaxis = list(title = "Average Rentals"))
    plotly_dark_layout(p)
  })

  # ---- Weather Impact ----
  output$weather_scatter_temp <- renderPlotly({
    d <- filtered_data()
    p <- plot_ly(d, x = ~temp_c, y = ~cnt, type = "scatter", mode = "markers",
                 marker = list(color = ~hum_pct, colorscale = list(
                                 list(0, gold_continuous(5)[1]),
                                 list(0.25, gold_continuous(5)[2]),
                                 list(0.5, gold_continuous(5)[3]),
                                 list(0.75, gold_continuous(5)[4]),
                                 list(1, gold_continuous(5)[5])),
                               showscale = TRUE, size = 8, opacity = 0.85,
                               colorbar = list(title = "Humidity (%)",
                                                tickfont = list(color = palette_black_gold$ivory),
                                                titlefont = list(color = palette_black_gold$ivory))),
                 hovertemplate = "Temp: %{x:.1f}\u00b0C<br>Rentals: %{y:,}<extra></extra>") %>%
      layout(xaxis = list(title = "Temperature (\u00b0C)"), yaxis = list(title = "Count of Rentals"))
    plotly_dark_layout(p)
  })

  output$weather_scatter_wind <- renderPlotly({
    d <- filtered_data()
    p <- plot_ly(d, x = ~windspeed_kmh, y = ~cnt, type = "scatter", mode = "markers",
                 marker = list(color = ~hum_pct, colorscale = list(
                                 list(0, gold_continuous(5)[1]),
                                 list(0.25, gold_continuous(5)[2]),
                                 list(0.5, gold_continuous(5)[3]),
                                 list(0.75, gold_continuous(5)[4]),
                                 list(1, gold_continuous(5)[5])),
                               showscale = TRUE, size = 8, opacity = 0.85,
                               colorbar = list(title = "Humidity (%)",
                                                tickfont = list(color = palette_black_gold$ivory),
                                                titlefont = list(color = palette_black_gold$ivory))),
                 hovertemplate = "Wind: %{x:.1f} km/h<br>Rentals: %{y:,}<extra></extra>") %>%
      layout(xaxis = list(title = "Wind Speed (km/h)"), yaxis = list(title = "Count of Rentals"))
    plotly_dark_layout(p)
  })

  # ---- Correlation ----
  output$corr_heatmap <- renderPlotly({
    d <- filtered_data()
    vars <- d %>% select(temp_c, atemp_c, hum_pct, windspeed_kmh, casual, registered, cnt)
    colnames(vars) <- c("Temperature", "Feels Like", "Humidity", "Wind Speed",
                         "Casual", "Registered", "Total Rentals")
    cm <- round(cor(vars, use = "complete.obs"), 2)

    p <- plot_ly(
      x = colnames(cm), y = colnames(cm), z = cm, type = "heatmap",
      colorscale = list(
        list(0, gold_continuous(5)[1]),
        list(0.25, gold_continuous(5)[2]),
        list(0.5, gold_continuous(5)[3]),
        list(0.75, gold_continuous(5)[4]),
        list(1, gold_continuous(5)[5])
      ),
      text = cm, texttemplate = "%{text}",
      hovertemplate = "%{x} vs %{y}: %{z}<extra></extra>"
    ) %>%
      layout(xaxis = list(title = ""), yaxis = list(title = ""))
    plotly_dark_layout(p)
  })

  # ---- Data Explorer ----
  output$data_table <- renderDT({
    d <- filtered_data() %>%
      select(Date = dteday, Season = season_lbl, Weather = weather_lbl,
             Weekday = weekday_lbl, `Day Type` = workingday_lbl,
             Holiday = holiday_lbl, `Temp (C)` = temp_c, `Humidity (%)` = hum_pct,
             `Wind (km/h)` = windspeed_kmh, Casual = casual,
             Registered = registered, Total = cnt)
    datatable(d, options = list(pageLength = 15, scrollX = TRUE),
              rownames = FALSE, class = "display compact") %>%
      formatRound(columns = c("Temp (C)", "Humidity (%)", "Wind (km/h)"), digits = 1) %>%
      formatStyle(columns = colnames(d), backgroundColor = palette_black_gold$panel,
                  color = palette_black_gold$ivory)
  })

  output$download_data <- downloadHandler(
    filename = function() paste0("bikeshare_filtered_", Sys.Date(), ".csv"),
    content = function(file) {
      write.csv(filtered_data(), file, row.names = FALSE)
    }
  )
}

# ---- 7. Run app ----------------------------------------------------------------
shinyApp(ui = ui, server = server)
