# Hotel Stays in Portugal: Time Series Analysis and Covid-19 Counterfactual Forecast
 
> **Note:** The report is written in **Italian**. This README provides a full description in English for accessibility.
 
## Overview
 
This project analyses the monthly time series of nights spent in Portuguese hotel accommodations from January 2010 to March 2024, based on Eurostat data. The goals are to describe the series and its components, fit a seasonal ARIMA model, and produce a counterfactual forecast to estimate what hotel stays would have looked like in early 2020 in the absence of the Covid-19 pandemic.
 
The work was developed as an individual project for the *Statistics for Tourism: Models and Applications* course at Università degli Studi di Milano-Bicocca (A.Y. 2023/24).
 
---
 
## Dataset
 
The dataset (`permanenze.csv`) contains 171 monthly observations from January 2010 to March 2024, sourced from **Eurostat**. The two variables are:
 
- `Mese`: month and year (character, converted to date format)
- `Portugal`: number of nights spent in Portuguese hotel structures (integer, rescaled to millions)
---
 
## Analysis
 
### Descriptive Analysis
- Time series plot, seasonal plot, and polar graph to visualise trend and seasonality
- Descriptive statistics: mean = 4.92M, median = 4.33M, min = 0.15M (April 2020), max = 12.18M (August 2023)
- ACF and ACVF plots: strong positive autocorrelation at lag 12 and its multiples, confirming annual seasonality
- Clear upward trend until early 2020, followed by a sharp drop due to Covid-19; annual peak consistently in August
### Time Series Decomposition
Multiplicative decomposition (chosen due to increasing seasonal variation over time) into:
- **Trend:** steady growth until 2020, then a sharp temporary decline
- **Seasonality:** regular alternating pattern with August peaks
- **Remainder:** small scale except during the Covid-affected months
### ARIMA Modelling
The model is estimated on the pre-COVID period (January 2010 – December 2019, 120 observations).
 
**Stationarization:**
- Box-Cox transformation (λ = 0, i.e. log transformation) to stabilise variance
- Seasonal differencing (lag 12) and first-order differencing to remove trend — resulting in 107 observations
**Model identification:**
ACF and PACF plots suggested ARIMA(2,1,2)(2,1,1)[12], which, however, showed residual autocorrelation at lags 12–13 and non-negligible fit deviations.
 
**Final model:** `auto.arima` (AICc minimisation) selected **ARIMA(0,0,1)(2,1,1)[12]**, which achieved a good fit with residuals approximately normally distributed, centred on zero, and not significantly autocorrelated.
 
### Counterfactual Forecast
The fitted model was used to forecast hotel nights for January–September 2020 (9-step ahead), with 80% and 95% prediction intervals. The forecast shows a continuation of the historical upward trend, in sharp contrast with the actual observed collapse in tourism during that period, quantifying the impact of COVID-19 on Portuguese hotel stays.
 
---
 
## Tech Stack
 
- **Language:** R
- **Key packages:** `forecast`, `tseries`, `ggplot2`, `feasts`, `fabletools`
---
 
## Author
 
Beatrice Malvezzi
*Statistics for Tourism: Models and Applications — A.Y. 2023/24, Università degli Studi di Milano-Bicocca*
