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
| [`src/analysis.R`](src/analysis.R) | Reorganized R analysis and ARIMA forecasting script |
| [`src/EconProjFf_original.R`](src/EconProjFf_original.R) | Preserved original academic R script |
| [`data/Gulf_Crisis_Finl.xlsx`](data/Gulf_Crisis_Finl.xlsx) | Observed 468-row panel dataset |
| [`data/panel_data_gulf_crisis_2026.xlsx`](data/panel_data_gulf_crisis_2026.xlsx) | Extended dataset including projected months |
| [`docs/Gulf_Crisis_Final_Report.pdf`](docs/Gulf_Crisis_Final_Report.pdf) | Original final academic report |
| [`docs/R_Output_Screenshot.docx`](docs/R_Output_Screenshot.docx) | Recorded R model output screenshots |

## Reproducibility

The reorganized script was executed successfully in [GitHub Actions](https://github.com/NouhaBoukhris/geopolitics-of-oil-econometric-analysis/actions/runs/43590051144), generating 468 processed observations and 72 ARIMA forecast rows. Matching all regression coefficients to the academic report is a separate validation step.

Install R dependencies:

```r
install.packages(c("readxl", "dplyr", "ggplot2", "plm", "lmtest", "stargazer", "forecast"))
```

From the repository root, run:

```bash
Rscript src/analysis.R
```

Generated outputs are written to the ignored `outputs/` folder. The extended dataset includes projected April–June 2026 values and must not be treated as additional observed panel data.

## Contributors

Group project by **Alaa Azouzi, Sarra Alioua, Nouha Boukhris, and Mariem Chammem**, completed for the Advanced Econometrics (BA351) course at Tunis Business School, academic year 2025–2026.

## Limitations

The work uses only one observed post-crisis month in its primary sample. Regression coefficients reflect model associations and rely on assumptions that require further scrutiny; forecasts do not incorporate subsequent observed economic data. The submitted report's numerical findings have not yet been independently reproduced from the accompanying spreadsheets.
