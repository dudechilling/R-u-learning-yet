\name{percentiles_quantiles}
\alias{percentiles_quantiles}
\alias{percentile}
\alias{quantiles}
\alias{quartiles}
\concept{percentile}
\concept{quantile}
\concept{quartile}
\concept{IQR}
\title{Percentiles, Quantiles and Quartiles}
\description{A \emph{quantile} marks a position in a distribution. The 0.75 quantile, or 75th percentile, is a cutoff at which roughly three quarters of observations fall at or below the value under the chosen convention. Quartiles divide a distribution into four portions.}
\section{Explanation}{To calculate a sample quantile, first order the measurements. Different conventions decide how to interpolate between ordered observations, especially with a small sample. R's \code{quantile()} has several calculation types, so different software can report slightly different values from the same data. The first quartile (Q1) is the 25th percentile, the median is the 50th percentile, and Q3 is the 75th percentile. Their difference is the IQR.}
\section{Practical example}{For recorded vehicle fuel economy in \code{mtcars$mpg}, use the 75th percentile to find a high-fuel-economy cutoff among those cars. The result is a statement about these records; it is not a guarantee that 75 percent of all vehicles have lower fuel economy.}
\section{Important distinctions}{A \emph{percentile cutoff} is a measured value, such as a fuel-economy figure. A \emph{percentile rank} describes where a given value stands within a distribution. Those are inverse questions. The empirical 90th percentile is not the same as the 90th percentile of an assumed normal model, which would use \code{qnorm()}.}
\section{Limitations}{Quantiles do not by themselves explain multimodality or sampling bias. For a small dataset, state R's quantile type if an exact numerical answer matters. Values can tie, and an interpolated quantile need not be an observed measurement.}
\section{R application}{Use \code{quantile(x, probs=c(.25,.5,.75))}, \code{IQR(x)} and optionally \code{ecdf(x)} for an empirical cumulative distribution. \code{probs} uses numbers between zero and one, not percentages written as whole numbers.}
\seealso{Related concepts: \link{mean_median}, \link{variance_sd}, \link{probability_distributions}, \link{confidence_intervals}. Native R help: \code{?quantile}, \code{?IQR}, \code{?qnorm}.}
\references{\url{https://search.r-project.org/R/refmans/stats/html/quantile.html}}
\examples{
data(mtcars)
quantile(mtcars$mpg, probs=c(.25,.5,.75))
IQR(mtcars$mpg)
quantile(mtcars$mpg, probs=.9)  # sample 90th percentile
# qnorm(.9, mean=20, sd=5) is instead a MODEL cutoff.
}