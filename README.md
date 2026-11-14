# The Geopolitics of Oil: Macroeconomic Impact & Forecasting

**Advanced Econometrics | R · Panel Data · ARIMA Forecasting**

This academic group project examines associations between macroeconomic indicators and consumer price levels across **12 advanced and emerging economies** around the 2026 Gulf oil-price shock. It combines panel regression, model diagnostics, group comparisons, and short-horizon time-series forecasting.

## Research overview

- **Panel:** 12 countries, monthly observations from January 2023 through March 2026 (468 country-month observations, as reported in the project).
- **Outcome:** natural log of the Consumer Price Index (CPI).
- **Regressors:** oil-price percentage change, nominal effective exchange rate, policy interest rate, global volatility (VIX), and a post-crisis indicator.
- **Estimators:** pooled OLS, country fixed effects, and random effects using R's `plm` package.
- **Diagnostics:** Breusch–Pagan LM, Hausman test, and heteroskedasticity-robust standard errors.
- **Forecasting:** ARIMA projections for CPI and industrial production (IPI), April–June 2026.

## Reported results

The original project report presents a **random-effects specification as preferred** based on the reported Hausman test (p = 0.2727), while the Breusch–Pagan LM test favors a panel specification over pooled OLS. It reports a negative association between the nominal effective exchange rate and log CPI and compares estimates for oil-importing versus oil-exporting economies.

**Interpretation caution:** These results should not be represented as identifying a causal effect of the oil shock. The original report states that the oil-price-change coefficient was not separately estimated and acknowledges endogeneity and the very short observed post-crisis period. ARIMA projections are *univariate forecasts*, not scenario-conditioned estimates of the geopolitical event.

## Project files

| Path | Description |
| --- | --- |
| `src/` | R analysis script (to be added) |
| `data/` | Original analysis spreadsheets (to be added) |
| [`docs/`](docs/) | [Final report](docs/Gulf_Crisis_Final_Report.pdf) and [R output screenshots](docs/R_Output_Screenshot.docx) |


## Reproducibility notes

The academic script uses an absolute local Windows file path and calls `install.packages()`. Before treating the code as reproducible, that path should be replaced with a relative file path, package installation should be documented separately, and data loading should be checked against the supplied workbook's sheets, headers, and dates. The archived source file and a cleaned runnable edition should remain distinguishable.

## Contributors

Group project by **Alaa Azouzi, Sarra Alioua, Nouha Boukhris, and Mariem Chammem**, completed for the Advanced Econometrics (BA351) course at Tunis Business School, academic year 2025–2026.

## Limitations

The work uses only one observed post-crisis month in its primary sample. Regression coefficients reflect model associations and rely on assumptions that require further scrutiny; forecasts do not incorporate subsequent observed economic data. The submitted report's numerical findings have not yet been independently reproduced from the accompanying spreadsheets.
