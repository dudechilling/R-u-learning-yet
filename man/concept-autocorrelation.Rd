\name{autocorrelation}
\alias{autocorrelation}
\alias{serial_correlation}
\alias{serial dependence}
\alias{lag_correlation}
\concept{autocorrelation}
\concept{serial dependence}
\concept{ACF}
\concept{lag}
\title{Autocorrelation and Time Lags}
\description{Autocorrelation describes how a time-ordered series relates to an earlier version of itself. Autocorrelation at lag one compares neighboring observations; lag two compares observations two steps apart. The lag refers to a defined spacing between observations.}
\section{Explanation}{A series might show persistence: warm days tend to follow warm days, or measurements fluctuate in a repeating cycle. The autocorrelation function (ACF) collects correlation values for several lags. An ACF differs from an ordinary correlation because it relates one variable to its own past. Conventional lag analysis assumes regular measurement intervals; when intervals vary, a difference of one observation is not a consistent time difference. A trend or seasonality can cause strong ACF values even if the underlying departures from the trend are less dependent.}
\section{Practical example}{The built-in \code{Nile} series contains annual flow measurements in chronological order. Plot it and run \code{acf()} to inspect how annual flow measurements relate across year lags. Compare this with data gathered at irregular time intervals; a standard ACF on those records would mislabel observation steps as equal elapsed time.}
\section{Important distinctions}{\emph{Autocorrelation} concerns one series at multiple times. \emph{Correlation} usually compares two different aligned variables. \emph{Trend} is a sustained directional change in level; \emph{seasonality} is a recurring calendar pattern. \emph{Stationarity} concerns whether statistical properties are stable, not whether all ACF values are zero.}
\section{Limitations}{A positive lag-one value does not identify a causal mechanism. ACF values and standard reference bands depend on assumptions such as stationarity and suitable sampling. Handle missing readings and duplicate or irregular timestamps before treating successive rows as equally spaced.}
\section{R application}{Use \code{plot(Nile)} for an overview and \code{acf(Nile)} for lag correlation. Specify the sampling interval when interpreting lags. Do not call a gap-filled sequence regularly spaced merely because missing rows were deleted.}
\seealso{Related concepts: \link{stationarity}, \link{time_series}, \link{trend}, \link{seasonality}, \link{correlation}. Native R help: \code{?acf}, \code{?plot}, \code{?diff}.}
\references{\url{https://itl.nist.gov/div898/handbook/eda/section3/eda35c.htm}

\url{https://www.itl.nist.gov/div898/handbook/pmc/section4/pmc442.htm}}
\examples{
flow <- Nile
plot(flow, main="Annual Nile River Flow", xlab="Year",
     ylab="River flow")
acf(flow, main="Nile autocorrelation by year lag")
# The observations here are annually spaced.
}