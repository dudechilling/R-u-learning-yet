\name{seasonality}
\alias{seasonality}
\alias{seasonal_pattern}
\alias{seasonal variation}
\concept{seasonality}
\concept{annual cycles}
\concept{periodic pattern}
\title{Seasonality in a Time Series}
\description{\emph{Seasonality} is a pattern that repeats at a known regular interval, such as annual cycles in monthly measurements or recurring differences between days of the week.}
\section{Explanation}{Monthly demand may be higher during the same part of each year. A seasonal pattern is a systematic calendar effect, not merely any ups and downs. Time plots and comparisons by month can help identify repetition. With only annual measurements, a monthly seasonal pattern cannot be recovered from the yearly totals. Repeated cycles may coexist with trends or changing variability.}
\section{Practical example}{The built-in \code{AirPassengers} series contains monthly airline passenger counts. Plot the series, then compare the monthly pattern. The example demonstrates how peaks and low points may repeat from year to year while the overall level also changes.}
\section{Important distinctions}{\emph{Seasonality} has a calendar-linked recurrence, unlike a general trend or irregular business-cycle fluctuation. \emph{Autocorrelation} may be large at seasonal lags, but the ACF alone does not identify why the pattern repeats. \emph{Stationarity} in its weak sense requires stable statistical properties; an unmodeled repeating seasonal mean challenges that condition.}
\section{Limitations}{A few repeated peaks do not prove a stable seasonal model. Changed measurement practices, missing months and calendar irregularities may distort comparisons. Seasonal adjustment is a transformation that needs to be disclosed.}
\section{R application}{Use \code{plot(AirPassengers)} for the time plot, \code{cycle()} for month positions and \code{tapply()} for an average by month. These are descriptive summaries rather than a fitted forecasting model.}
\seealso{Related concepts: \link{time_series}, \link{trend}, \link{stationarity}, \link{autocorrelation}. Native R help: \code{?plot}, \code{?cycle}, \code{?tapply}.}
\references{\url{https://www.itl.nist.gov/div898/handbook/pmc/section4/pmc442.htm}}
\examples{
data(AirPassengers)
plot(AirPassengers, main="Monthly airline passengers",
     ylab="Passengers", xlab="Year")
monthly_mean <- tapply(as.numeric(AirPassengers),
                       cycle(AirPassengers), mean)
print(monthly_mean)
# Overall growth and repeating month patterns can coexist.
}