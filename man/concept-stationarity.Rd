\name{stationarity}
\alias{stationarity}
\alias{weak_stationarity}
\alias{covariance_stationarity}
\alias{stationary series}
\concept{stationarity}
\concept{weak stationarity}
\concept{time series}
\concept{stable mean}
\concept{autocovariance}
\title{Stationarity in a Time Series}
\description{\emph{Weak stationarity} means that a time-dependent process has a constant expected mean, constant finite variance, and autocovariance between two observations that depends on their time lag rather than their position on the calendar. The readings themselves do not have to be identical.}
\section{Explanation}{Every series has some variation. Stationarity is not a claim that a river carries the same water every year or that a weather station repeats the same reading. It describes a \emph{stable statistical process}: readings fluctuate around the same long-run level, with similar variance and dependence over time. A persistent upward trend changes the expected mean. Increasing volatility changes the variance. A change in the way observations depend on previous observations changes the autocovariance structure. Many forecasting procedures rely on such properties; using them without checking the relevant assumptions can distort uncertainty and prediction.}
\section{Practical example}{Think about a river gauge operating at one location. Its annual flow readings naturally change with rain and snowmelt. Those changes alone do not show nonstationarity. A sustained shift in typical annual flow, persistent growth in year-to-year variation, or a change in how one year predicts the next would challenge weak stationarity. The built-in \code{Nile} series records 100 annual river-flow observations; comparing the first 50 years with the last 50 is a useful exploratory exercise.}
\section{Important distinctions}{A \emph{constant sensor location} does not imply stationarity of the measured process. \emph{No trend} is not sufficient for stationarity because variance or autocovariance may change. A \emph{white-noise} series has no serial correlation, whereas a weakly stationary series may have strong, stable autocorrelation. \emph{Strict stationarity} is a stronger distribution-wide requirement and is not interchangeable with weak stationarity. \emph{Seasonality} and \emph{trend} need separate investigation.}
\section{Limitations}{Two similar or different window averages cannot prove or disprove stationarity on their own; sampling variability can produce differences even for a stationary process. Comparing windows is \emph{exploratory}. Missing time points and unequal observation intervals must be investigated before interpreting \code{acf()} lag values. Transformations such as differencing change the question and should have a clear purpose.}
\section{R application}{Plot a time series first. Use \code{mean()} and \code{sd()} on separate windows to explore changes in center and spread. Use \code{acf()} for serial dependence when observations are regularly spaced. Explain what each graph shows without treating a diagnostic as definitive.}
\seealso{Related concepts: \link{time_series}, \link{mean_median}, \link{variance_sd}, \link{autocorrelation}, \link{trend}, \link{seasonality}. Native R help: \code{?plot}, \code{?mean}, \code{?sd}, \code{?acf}.}
\references{\url{https://www.itl.nist.gov/div898/handbook/pmc/section4/pmc442.htm}

\url{https://itl.nist.gov/div898/handbook/eda/section3/eda35c.htm}}
\examples{
flow <- Nile
plot(flow, main="Annual Nile River Flow",
     xlab="Year", ylab="River flow")
mean(flow[1:50])             # early window
mean(flow[51:100])           # late window
sd(flow[1:50])               # early spread
sd(flow[51:100])             # late spread
acf(flow)
# Window comparisons and the ACF are exploratory, NOT proof.
}