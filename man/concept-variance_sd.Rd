\name{variance_sd}
\alias{variance_sd}
\alias{standard_deviation}
\alias{standard deviation}
\alias{spread}
\concept{variance}
\concept{standard deviation}
\concept{spread}
\concept{dispersion}
\title{Variance and Standard Deviation}
\description{Standard deviation tells how spread out numerical observations are around their mean (average). It is measured in the original units. Variance measures spread using squared distances from the mean and has squared units; R uses the sample formula unless stated otherwise.}
\section{Explanation}{For a sample, R's \code{var(x)} divides the sum of squared deviations from the sample mean by \code{n - 1}; \code{sd(x)} takes its square root. A larger standard deviation indicates more spread around the mean, not necessarily more measurement error. Because squaring gives extra weight to extreme departures, both measures respond strongly to outliers. A standard deviation of zero means all usable values are identical.}
\section{Practical example}{Use \code{iris$Petal.Length}, measured in centimetres. The sample variance is expressed in squared centimetres; the sample standard deviation is in centimetres. Compare distributions by species before assuming the pooled spread describes one homogeneous group.}
\section{Important distinctions}{The \emph{range} is maximum minus minimum. The \emph{interquartile range} is the distance between the third and first quartiles. The \emph{standard error of the mean} estimates sampling uncertainty of an average, and is not the same quantity as the standard deviation of individual observations. Population variance uses a different denominator when all population units are actually known.}
\section{Limitations}{Standard deviation alone does not reveal skew, clusters or the cause of variability. For a highly skewed distribution or extreme outliers, also inspect a histogram, median and IQR. Be clear whether the dataset is a sample or the entire defined population.}
\section{R application}{Use \code{var(x)} and \code{sd(x)} for a numeric vector and \code{na.rm=TRUE} only after checking why observations are missing. \code{sd()} requires at least two usable values for a finite result. See \code{?sd} and \code{?var}.}
\seealso{Related concepts: \link{mean_median}, \link{population_sample}, \link{percentiles_quantiles}, \link{sampling_distributions}, \link{stationarity}. Native R help: \code{?sd}, \code{?var}, \code{?boxplot}.}
\references{\url{https://search.r-project.org/R/refmans/stats/html/sd.html}}
\examples{
data(iris)
x <- iris$Petal.Length
mean(x)
var(x)        # squared centimetres
sd(x)         # centimetres
IQR(x)        # spread of middle 50 percent
}