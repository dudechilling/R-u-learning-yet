---
id: stationarity
type: concept
domain: Spatial, temporal, and modelling
aliases: weak stationary;stationary time series;stationarity;stable mean variance autocovariance;forecast stationarity
related: autocorrelation;time_series;trend;seasonality
visual:
alt:
caption:
sources: https://search.r-project.org/R/refmans/stats/html/acf.html
status: VERIFIED
---
# What does weak stationarity mean in a time series?

## Immediate answer

Weak stationarity means the series has a constant mean and finite, constant variance through time, while covariance between two observations depends on their time lag rather than the calendar dates. Individual readings need not be equal.

## Exam answer pattern

Name mean, variance and lag-dependent covariance. Explain that a stationary measuring station at one location does not imply its measurements form a stationary statistical series.

## What to check

- A visually flat mean alone does not prove stationarity.
- Seasonal patterns or trend can violate the assumptions.
- Autocorrelation may exist in a stationary series.

## Interpret your results

For forecasting, changes in mean or dependence over time can make a model fitted to earlier observations unreliable. Diagnose with plots and subject knowledge before assuming a stable process.

## Learn more

A test or sample autocorrelation does not certify all stationarity conditions. Definitions differ for strict and weak stationarity.
