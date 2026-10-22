\name{trend}
\alias{trend}
\alias{trend_concept}
\alias{time trend}
\concept{trend}
\concept{time trend}
\concept{changing mean}
\title{Trend in Time-Ordered Data}
\description{A \emph{trend} is a persistent, systematic change in a time series' typical level over an extended period, such as a long-term increase or decrease. Individual observations may still rise and fall around it.}
\section{Explanation}{A river can have several unusually wet years without a long-term trend. A trend is about an evolving baseline, not simply differences between adjacent readings. A fitted line can summarize a possible trend but only after considering time intervals, seasonal variation, dependence and changes in how measurements were collected. A positive fitted slope over a short sample does not guarantee future increases.}
\section{Practical example}{Plot \code{Nile} annual flow against year. You can add a descriptive straight-line fit to see a possible average change. Whether the change represents climate, a changed river system or measurement differences is a separate question requiring evidence.}
\section{Important distinctions}{\emph{Seasonality} repeats with a defined calendar interval; a trend is not cyclic by definition. \emph{Stationarity} with a constant mean is inconsistent with a deterministic changing mean, although analysts can sometimes remove or model a trend to study remaining variation. \emph{Autocorrelation} describes dependence at different lags, which can be influenced by trend.}
\section{Limitations}{A regression slope in time-ordered data can be unreliable if serial dependence is ignored. Descriptive trend lines do not prove causes. Trend removal changes what remains under study, and a straight line may be inappropriate for a nonlinear change.}
\section{R application}{Plot the data first. A descriptive line from \code{lm()} can make a possible direction visible, but significance tests and uncertainty need assumptions about the errors and the design.}
\seealso{Related concepts: \link{time_series}, \link{stationarity}, \link{autocorrelation}, \link{seasonality}. Native R help: \code{?plot}, \code{?lm}, \code{?abline}.}
\references{\url{https://www.itl.nist.gov/div898/handbook/pmc/section4/pmc442.htm}}
\examples{
flow <- as.numeric(Nile)
years <- as.numeric(time(Nile))
plot(years, flow, pch=19, xlab="Year", ylab="Flow")
line <- lm(flow ~ years)
abline(line, col="blue", lwd=2)
# This is a descriptive fitted line, not a causal claim.
}