# ============================================================================
# COMPLETE SCRIPT — Geopolitics of Oil: Panel Data Analysis
# ============================================================================

# STEP 1: INSTALL PACKAGES (only needed once — skip if already installed)
install.packages(c("tidyverse", "plm", "lmtest", "stargazer", "ggplot2", "car", "readxl"))

# STEP 2: LOAD LIBRARIES
library(readxl)
library(dplyr)
library(ggplot2)
library(plm)
library(lmtest)
library(stargazer)
library(car)

# ============================================================================
# STEP 3: LOAD DATA
# ============================================================================

# *** UPDATE THIS PATH TO YOUR FILE LOCATION ***
data_raw <- read_excel(
  "C:/Users/chamm/Downloads/Gulf_Crisis_Finl.xlsx",
  sheet     = "Gulf_Crisis",
  skip      = 2,
  col_names = c("country", "date", "group", "oil_balance",
                "cpi", "ipi", "brent", "neer", "policy_rate", "vix")
)

# Drop the pre-computed columns — we only need the 10 raw ones
data_raw <- data_raw[, c("country", "date", "group", "oil_balance",
                         "cpi", "ipi", "brent", "neer", "policy_rate", "vix")]

# Force correct data types
data_raw$date        <- as.Date(as.character(data_raw$date))
data_raw$cpi         <- as.numeric(as.character(data_raw$cpi))
data_raw$ipi         <- as.numeric(as.character(data_raw$ipi))
data_raw$brent       <- as.numeric(as.character(data_raw$brent))
data_raw$neer        <- as.numeric(as.character(data_raw$neer))
data_raw$policy_rate <- as.numeric(as.character(data_raw$policy_rate))
data_raw$vix         <- as.numeric(as.character(data_raw$vix))
data_raw$country     <- as.character(data_raw$country)
data_raw$group       <- as.character(data_raw$group)
data_raw$oil_balance <- as.character(data_raw$oil_balance)

# Remove any leftover header rows (rows where country is not a 3-letter code)
data_raw <- data_raw[nchar(trimws(data_raw$country)) == 3, ]

cat("Rows loaded:", nrow(data_raw), "\n")
cat("Columns:", names(data_raw), "\n")

# ============================================================================
# STEP 4: COMPUTE DERIVED VARIABLES
# ============================================================================

data_processed <- data_raw %>%
  group_by(country) %>%
  arrange(date, .by_group = TRUE) %>%
  mutate(
    ln_cpi         = log(cpi),
    ln_ipi         = log(ipi),
    ln_neer        = log(neer),
    post_crisis    = ifelse(date >= as.Date("2026-03-01"), 1, 0),
    oil_pct_change = (brent - lag(brent)) / lag(brent) * 100,
    oil_pct_change = ifelse(is.na(oil_pct_change), 0, oil_pct_change)
  ) %>%
  ungroup() %>%
  filter(!is.na(ln_cpi), !is.na(ln_ipi), !is.na(oil_pct_change))

cat("data_processed rows:", nrow(data_processed), "\n")

# ============================================================================
# STEP 5: EXPLORATORY DATA ANALYSIS
# ============================================================================

# Plot 1: Brent oil price over time
ggplot(data_processed %>% distinct(date, brent), aes(x = date, y = brent)) +
  geom_line(color = "darkred", linewidth = 1) +
  geom_vline(xintercept = as.numeric(as.Date("2026-02-27")),
             linetype = "dashed", color = "blue") +
  annotate("text", x = as.Date("2026-02-27"), y = max(data_processed$brent),
           label = "Crisis Start", hjust = -0.1) +
  labs(title = "Brent Crude Oil Price: Pre and Post 2026 Gulf Crisis",
       x = "Date", y = "USD per Barrel") +
  theme_minimal()

# Plot 2: Log CPI trends by country group
ggplot(data_processed, aes(x = date, y = ln_cpi, color = group)) +
  stat_summary(fun = mean, geom = "line", linewidth = 1) +
  geom_vline(xintercept = as.numeric(as.Date("2026-02-27")),
             linetype = "dashed") +
  labs(title = "Log CPI Trends by Country Group",
       x = "Date", y = "Log(CPI)") +
  theme_minimal()

# ============================================================================
# STEP 6: DECLARE PANEL STRUCTURE
# ============================================================================

pdata <- pdata.frame(data_processed, index = c("country", "date"))

# ============================================================================
# STEP 7: PANEL REGRESSIONS
# ============================================================================

# Model 1: Pooled OLS
pols_model <- plm(
  ln_cpi ~ oil_pct_change + ln_neer + policy_rate + vix + post_crisis,
  data  = pdata,
  model = "pooling"
)
summary(pols_model)

# Model 2: Fixed Effects
fe_model <- plm(
  ln_cpi ~ oil_pct_change + ln_neer + policy_rate + vix + post_crisis,
  data  = pdata,
  model = "within"
)
summary(fe_model)

# Model 3: Random Effects
re_model <- plm(
  ln_cpi ~ oil_pct_change + ln_neer + policy_rate + vix + post_crisis,
  data  = pdata,
  model = "random"
)
summary(re_model)

# Comparison table
stargazer(pols_model, fe_model, re_model,
          title         = "Panel Regression Results: CPI Equation",
          column.labels = c("Pooled OLS", "Fixed Effects", "Random Effects"),
          type          = "text",
          keep.stat     = c("n", "rsq"))

# ============================================================================
# STEP 8: DIAGNOSTIC TESTS
# ============================================================================

# Hausman Test
hausman_test <- phtest(fe_model, re_model)
print(hausman_test)

# Breusch-Pagan Test
bp_test <- plmtest(pols_model, effect = "individual", type = "bp")
print(bp_test)

# Robust Standard Errors
cat("\n--- Pooled OLS (Robust SE) ---\n")
print(coeftest(pols_model, vcov = vcovHC(pols_model, type = "HC3")))

cat("\n--- Fixed Effects (Robust SE) ---\n")
print(coeftest(fe_model, vcov = vcovHC(fe_model, method = "arellano", type = "HC3")))

cat("\n--- Random Effects (Robust SE) ---\n")
print(coeftest(re_model, vcov = vcovHC(re_model, method = "arellano", type = "HC3")))

# ============================================================================
# STEP 9: HETEROGENEITY ANALYSIS
# ============================================================================

importers_data <- pdata %>% filter(oil_balance == "importer")
exporters_data <- pdata %>% filter(oil_balance == "exporter")

fe_importers <- plm(
  ln_cpi ~ oil_pct_change + ln_neer + policy_rate + vix + post_crisis,
  data  = importers_data,
  model = "within"
)

fe_exporters <- plm(
  ln_cpi ~ oil_pct_change + ln_neer + policy_rate + vix + post_crisis,
  data  = exporters_data,
  model = "within"
)

stargazer(fe_importers, fe_exporters,
          title         = "Fixed Effects Results: Oil Importers vs. Exporters",
          column.labels = c("Importers", "Exporters"),
          type          = "text",
          keep.stat     = c("n", "rsq"))

# ============================================================================
# Step 10: ARIMA FORECASTING: April – June 2026
# ============================================================================

install.packages("forecast")
library(forecast)

# Countries and variables to forecast
countries  <- unique(data_processed$country)
vars       <- c("cpi", "ipi")
h          <- 3  # forecast 3 months ahead (Apr, May, Jun 2026)

forecast_rows <- list()

for (ctry in countries) {
  
  country_data <- data_processed %>%
    filter(country == ctry) %>%
    arrange(date)
  
  for (var in vars) {
    
    # Extract the time series
    ts_data <- ts(country_data[[var]],
                  start     = c(2023, 1),
                  frequency = 12)
    
    # Fit ARIMA model automatically
    fit <- auto.arima(ts_data)
    
    # Forecast 3 months ahead
    fc <- forecast(fit, h = h)
    
    # Store forecasted values
    for (i in 1:h) {
      forecast_rows[[length(forecast_rows) + 1]] <- data.frame(
        country     = ctry,
        date        = as.Date(paste0("2026-0", 3 + i, "-01")),
        variable    = var,
        forecast    = as.numeric(fc$mean[i]),
        lower_95    = as.numeric(fc$lower[i, 2]),
        upper_95    = as.numeric(fc$upper[i, 2]),
        stringsAsFactors = FALSE
      )
    }
    
    # Print the forecast for each country/variable
    cat("\n===", ctry, "-", var, "===\n")
    print(fc)
    plot(fc, main = paste("ARIMA Forecast:", ctry, "-", var))
  }
}

# Combine all forecasts into one table
forecast_df <- do.call(rbind, forecast_rows)

# View the full forecast table
print(forecast_df)

