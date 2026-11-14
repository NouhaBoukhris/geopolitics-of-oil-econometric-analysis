# Reproducible portfolio edition of the academic panel-data analysis.
# Original submitted script: EconProjFf.r (keep separately when uploading).
# Run from the repository root after installing packages in README.
library(readxl)
library(dplyr)
library(ggplot2)
library(plm)
library(lmtest)
library(stargazer)
library(forecast)

input <- "data/Gulf_Crisis_Finl.xlsx"
if (!file.exists(input)) stop("Missing ", input, ". Upload the original workbook to data/.")
dir.create("outputs", showWarnings = FALSE)

raw <- read_excel(input, sheet = "Gulf_Crisis", skip = 2,
                  col_names = c("country","date","group","oil_balance",
                                "cpi","ipi","brent","neer","policy_rate","vix"))
raw <- raw[, 1:10]
raw <- raw %>%
  mutate(country = as.character(country),
         date = as.Date(as.character(date)),
         across(c(cpi,ipi,brent,neer,policy_rate,vix), as.numeric),
         group = as.character(group), oil_balance = as.character(oil_balance)) %>%
  filter(nchar(trimws(country)) == 3)
if (nrow(raw) != 468) warning("Expected 468 rows in the archived analysis workbook; found ", nrow(raw))
if (anyDuplicated(raw[c("country","date")])) stop("Duplicate country-month keys")

processed <- raw %>%
  group_by(country) %>% arrange(date, .by_group = TRUE) %>%
  mutate(ln_cpi = log(cpi), ln_ipi = log(ipi), ln_neer = log(neer),
         post_crisis = as.integer(date >= as.Date("2026-03-01")),
         oil_pct_change = (brent - lag(brent))/lag(brent)*100,
         oil_pct_change = ifelse(is.na(oil_pct_change), 0, oil_pct_change)) %>%
  ungroup() %>%
  filter(!is.na(ln_cpi), !is.na(ln_ipi), !is.na(oil_pct_change))
write.csv(processed, "outputs/processed_panel.csv", row.names = FALSE)

p1 <- ggplot(distinct(processed, date, brent), aes(date, brent)) +
  geom_line(color = "darkred", linewidth = 1) +
  geom_vline(xintercept = as.Date("2026-02-27"), linetype = "dashed") +
  labs(title = "Brent crude oil price", x = "Date", y = "USD per barrel") + theme_minimal()
ggsave("outputs/brent_trend.png", p1, width = 9, height = 5, dpi = 160)
p2 <- ggplot(processed, aes(date, ln_cpi, color = group)) +
  stat_summary(fun = mean, geom = "line") +
  geom_vline(xintercept = as.Date("2026-02-27"), linetype = "dashed") +
  labs(title = "Mean log CPI by country group", x = "Date", y = "Log CPI") + theme_minimal()
ggsave("outputs/cpi_trends.png", p2, width = 9, height = 5, dpi = 160)

pdata <- pdata.frame(processed, index = c("country", "date"))
formula <- ln_cpi ~ oil_pct_change + ln_neer + policy_rate + vix + post_crisis
pooled <- plm(formula, data = pdata, model = "pooling")
fixed <- plm(formula, data = pdata, model = "within")
random <- plm(formula, data = pdata, model = "random")
sink("outputs/model_results.txt")
cat("POOLED OLS\n"); print(summary(pooled))
cat("\nFIXED EFFECTS\n"); print(summary(fixed))
cat("\nRANDOM EFFECTS\n"); print(summary(random))
cat("\nHAUSMAN\n"); print(phtest(fixed, random))
cat("\nBREUSCH-PAGAN LM\n"); print(plmtest(pooled, effect = "individual", type = "bp"))
cat("\nROBUST STANDARD ERRORS\n")
print(coeftest(pooled, vcov. = vcovHC(pooled, type = "HC3")))
print(coeftest(fixed, vcov. = vcovHC(fixed, method = "arellano", type = "HC3")))
print(coeftest(random, vcov. = vcovHC(random, method = "arellano", type = "HC3")))
cat("\nOIL IMPORTERS VS EXPORTERS (FIXED EFFECTS)\n")
for (balance in c("importer", "exporter")) {
  subset_panel <- pdata[pdata$oil_balance == balance, ]
  cat("\n", balance, "\n")
  print(summary(plm(formula, data = subset_panel, model = "within")))
}
sink()

# Three-month univariate ARIMA projections, April–June 2026.
forecast_rows <- list()
for (ctry in unique(processed$country)) {
  country_data <- processed %>% filter(country == ctry) %>% arrange(date)
  for (variable in c("cpi", "ipi")) {
    values <- ts(country_data[[variable]], start = c(2023,1), frequency = 12)
    fc <- forecast(auto.arima(values), h = 3)
    forecast_rows[[length(forecast_rows)+1]] <- data.frame(
      country = ctry, date = as.Date(c("2026-04-01","2026-05-01","2026-06-01")),
      variable = variable, forecast = as.numeric(fc$mean),
      lower_95 = as.numeric(fc$lower[,2]), upper_95 = as.numeric(fc$upper[,2]))
  }
}
write.csv(do.call(rbind, forecast_rows), "outputs/arima_forecasts.csv", row.names = FALSE)
cat("Finished. See outputs/.\n")
