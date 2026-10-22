\name{time_series}
\alias{time_series}
\alias{time_series_concept}
\alias{time series}
\concept{time series}
\concept{time indexing}
\concept{sampling interval}
\title{Time Series and Ordered Observations}
\description{A \emph{time series} is a sequence of observations indexed by time. The order and the elapsed interval between readings are part of the information, not optional labels.}
\section{Explanation}{Hourly temperatures and annual river-flow measurements both form time series, but one observation lag means one hour in the first and one year in the second only when the readings are regularly spaced. A line plot helps locate spikes, trends, recurring patterns and missing periods. Store actual dates or times whenever possible. Sorting by time is necessary, but sorting cannot recreate missing measurements or prove that the intervals were constant.}
\section{Practical example}{The built-in \code{Nile} series contains one annual flow observation per year. Plot it with a year axis and inspect whether the process appears to change across decades. A set of randomly spaced measurement dates would require special care before applying methods that treat adjacent rows as fixed elapsed-time lags.}
\section{Important distinctions}{The \emph{observation order} is not the same as the \emph{calendar spacing}. \emph{Trend} concerns a sustained change, \emph{seasonality} a regularly recurring pattern and \emph{autocorrelation} the relationship to earlier readings. \emph{Stationarity} concerns stable statistical properties of the generating process.}
\section{Limitations}{Straight line segments in a chart do not prove smooth changes occurred between measurements. Duplicate timestamps and omitted readings can make ACF analysis misleading. A time series does not by itself reveal what caused a change.}
\section{R application}{Use \code{plot()} on a \code{ts} object such as \code{Nile}; use \code{time()} to inspect time positions. Keep timestamps aligned with observations in a data frame when working with external files.}
\seealso{Related concepts: \link{autocorrelation}, \link{stationarity}, \link{trend}, \link{seasonality}. Native R help: \code{?plot}, \code{?time}, \code{?acf}.}
\references{\url{https://www.itl.nist.gov/div898/handbook/pmc/section4/pmc442.htm}}
\examples{
flow <- Nile
plot(flow, main="Annual Nile River Flow",
     xlab="Year", ylab="Flow")
head(time(flow))
head(as.numeric(flow))
# These measurements have annual spacing.
}