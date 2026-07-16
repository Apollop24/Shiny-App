# 🖤✨ Capital Bikeshare Intelligence Dashboard

**Black & Gold Elegance Edition** — a professional, interactive Shiny application for exploring the UCI Capital Bikeshare dataset (2011–2012).

![R](https://img.shields.io/badge/R-4.3%2B-D4AF37?style=for-the-badge&logo=r&logoColor=white&labelColor=0A0A0A)
![Shiny](https://img.shields.io/badge/Shiny-Dashboard-D4AF37?style=for-the-badge&logo=rstudio&logoColor=white&labelColor=0A0A0A)
![Plotly](https://img.shields.io/badge/Plotly-Interactive-D4AF37?style=for-the-badge&logo=plotly&logoColor=white&labelColor=0A0A0A)
![License](https://img.shields.io/badge/License-MIT-D4AF37?style=for-the-badge&labelColor=0A0A0A)

---

## Table of Contents

- [Overview](#overview)
- [Design Language](#design-language)
- [Data Source](#data-source)
- [Attribute Information](#attribute-information)
- [Features](#features)
- [Project Structure](#project-structure)
- [Installation](#installation)
- [Usage](#usage)
- [Screenshots](#screenshots)
- [Tech Stack](#tech-stack)
- [Author](#author)
- [License](#license)

---

## Overview

This repository contains a full redesign of an earlier beginner-level bike-rental Shiny app, rebuilt as a **production-grade analytics dashboard**. It is organized into six analytical modules — Executive Overview, Distribution, Seasonality & Weekday, Weather Impact, Correlation, and a searchable Data Explorer — all driven by a single set of shared, reactive filters (date range, season, weather situation, day type, and holiday status).

Every chart in the application shares **one consistent visual language** rather than a different colour per plot: continuous variables (humidity, correlation strength) are mapped along a single navy-to-gold gradient, and categorical variables draw from the same gold-to-charcoal family. The result is a cohesive, boardroom-ready dashboard rather than a patchwork of default `ggplot2`/`plotly` colours.

## Design Language

**Black & Gold Elegance**

| Role | Colour | Hex |
|---|---|---|
| Base black | ⬛ | `#0B0B0C` |
| Deep navy | 🟦 | `#0A1128` |
| Navy mid-tone | 🟦 | `#14213D` |
| Deep gold | 🟨 | `#8C6A1F` |
| Regal gold | 🟨 | `#D4AF37` |
| Bright gold | 🟨 | `#F4C430` |
| Ivory / white | ⬜ | `#F5F1E6` |

This palette is defined once in `app.R` (`palette_black_gold`) and consumed everywhere — KPI cards, navigation, sliders, buttons, tables, and every Plotly chart — so the identity stays consistent as the dashboard grows.

## Data Source

The application uses the **UCI Capital Bikeshare Dataset** (`day.csv`), containing 731 daily records from the Capital Bikeshare system in Washington, D.C. across 2011–2012, together with the corresponding weather and seasonal information.

> Fanaee-T, H. (2013). *Bike Sharing* [Dataset]. UCI Machine Learning Repository. https://doi.org/10.24432/C5W894

## Attribute Information

| Field | Description |
|---|---|
| `dteday` | Date of the rental |
| `season` | Season (1: Winter, 2: Spring, 3: Summer, 4: Fall) |
| `yr` | Year (0: 2011, 1: 2012) |
| `mnth` | Month (1–12) |
| `holiday` | Whether the day is a holiday |
| `weekday` | Day of the week |
| `workingday` | Whether the day is a working day |
| `weathersit` | Weather situation (1: Clear, 2: Mist + Cloudy, 3: Light Snow/Rain, 4: Heavy Rain/Storm) |
| `temp` / `atemp` | Normalized temperature / feels-like temperature (°C) |
| `hum` | Normalized humidity |
| `windspeed` | Normalized wind speed |
| `casual` / `registered` / `cnt` | Casual, registered, and total daily rental counts |

## Features

- **Global reactive filters** — date range, season, weather situation, day type, and holiday status apply across every tab simultaneously.
- **Executive KPI cards** — total rentals, average daily rentals, registered rider share, and peak-day volume, recalculated live as filters change.
- **Six analytical modules**
  - *Executive Overview* — rental trend over time, casual vs. registered stacked area, and seasonal totals.
  - *Distribution* — adjustable-bin histogram and kernel-density comparison by day type.
  - *Seasonality & Weekday* — grouped boxplots by weekday/day type, monthly trend line, and weather-situation comparison.
  - *Weather Impact* — temperature and wind-speed scatter plots, both coloured on the same humidity gradient.
  - *Correlation* — a full correlation heatmap across temperature, humidity, wind speed, and ridership.
  - *Data Explorer* — a searchable, sortable data table with a one-click CSV export of the currently filtered data.
- **One shared colour system** — no per-chart colour guesswork; every plot reads as part of the same design.
- **Fully interactive** — built on `plotly` for zoom, pan, hover tooltips, and legend toggling on every chart.
- **Offline-friendly** — no external font or asset downloads at runtime, so the app runs the same in RStudio, Posit Cloud, Docker, or a bare `Rscript` call.

## Project Structure

```
bike-shiny-app/
├── app.R          # Complete Shiny application (UI + server + data prep)
├── day.csv        # UCI Capital Bikeshare daily dataset
├── www/           # Static assets folder (reserved for custom assets)
├── README.md      # This file
├── LICENSE        # MIT License
└── .gitignore     # R / RStudio ignore rules
```

## Installation

Requires **R 4.1+**. Install the required packages:

```r
install.packages(c(
  "shiny", "bslib", "plotly", "dplyr", "tidyr",
  "DT", "scales", "lubridate"
))
```

The app installs any missing package automatically on first launch as a convenience fallback, but pre-installing is recommended for a faster first run.

## Usage

Clone the repository and launch the app from its own directory:

```r
# From within the bike-shiny-app/ directory
shiny::runApp("app.R")
```

Or, from the command line:

```bash
Rscript -e 'shiny::runApp("app.R", launch.browser = TRUE)'
```

The dashboard will open in your default web browser. `day.csv` is read relative to the app's own location, so no path editing is required.

## Screenshots

> Add a screenshot of the running dashboard here after your first local launch, for example:
>
> `![Dashboard preview](www/dashboard-preview.png)`

## Tech Stack

- **R** — core language
- **Shiny** — reactive web application framework
- **bslib** — Bootstrap 5 theming engine (custom Black & Gold Elegance theme)
- **plotly** — interactive charting
- **dplyr / tidyr** — data wrangling
- **DT** — interactive data tables
- **scales / lubridate** — formatting and date handling

## Author

**Kibet Philip**
Data Analyst · Statistician · Data Scientist
GitHub: [@Apollop24](https://github.com/Apollop24)

## License

Released under the [MIT License](LICENSE).
