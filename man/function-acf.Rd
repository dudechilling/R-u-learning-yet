\name{function_acf}
\alias{r_acf}
\alias{function_acf}
\concept{R function acf}
\title{acf() - Autocorrelation by Lag}
\description{\code{acf()} examines correlation between a time-ordered series and lagged copies of itself. It is useful for detecting persistence or recurring patterns, but results assume that successive observation steps represent consistent elapsed-time intervals.}
\section{Syntax}{\preformatted{acf(x, lag.max = NULL, type = "correlation", plot = TRUE)}}
\section{Important arguments}{\code{x} should be a regular, numeric time series; \code{lag.max} limits how many lags are shown; \code{type} determines correlation versus covariance; \code{plot=FALSE} returns the values without drawing a graph. For a \code{ts} object, the plotted lag-axis labels reflect its frequency.}
\section{What it returns}{An \code{acf} object with lag values and estimated correlations. Large estimates do not themselves prove causes, stationarity, or a suitable forecasting model.}
\section{Common mistakes}{If one reading is missing and dropped, the remaining rows may no longer be regularly spaced. Do not call a lag-one result "one day" when observations are irregular or sampled less often. A trend can produce large correlations even when a different model for residuals is needed.}
\section{Adapt the example}{Replace \code{Nile} with a regularly spaced time series with known interval, plot it first, and investigate gaps and time changes. Use the stationarity reference to understand the assumptions.}
\seealso{Native R documentation: \code{\link[stats]{acf}}. Concepts: \link{autocorrelation}, \link{stationarity}, \link{time_series}, \link{trend}. Walkthrough: \code{ru_guide("autocorrelation")}.}
\references{Native help: \code{help("acf", package="stats")}. \url{https://search.r-project.org/R/refmans/stats/html/00Index.html}}
\examples{
flow <- Nile
plot(flow,main="Annual flow",xlab="Year",ylab="Flow")
result <- acf(flow,plot=FALSE)
plot(result,main="Nile lag correlations")
}