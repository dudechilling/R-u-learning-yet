\name{function_median}
\alias{r_median}
\alias{function_median}
\concept{R function median}
\title{median() - Find the Middle Ordered Value}
\description{\code{median()} orders the observations and returns the middle value. With an even number of values, it averages the two middle values. The median describes the middle rank and is less sensitive than the mean to extreme measurements.}
\section{Syntax}{\preformatted{median(x, na.rm = FALSE)}}
\section{Important arguments}{\code{x} is an ordered or numeric vector whose median is meaningful. \code{na.rm} determines whether missing entries are removed. Always check how missing values arose before discarding them.}
\section{What it returns}{One median value in the measurement units. It does not tell you how widely the observations vary or whether the distribution has several peaks.}
\section{Common mistakes}{An even-sized sample can have a median that was not an observed value. Confusing the median with a mode or with a probability percentile can lead to a wrong interpretation. Do not use median for unordered category labels.}
\section{Adapt the example}{Replace \code{faithful$eruptions} with another numerical column. Compare with \code{mean(x)} and a histogram to see why the median may describe the center more faithfully when a few measurements are extreme.}
\seealso{Native R documentation: \code{\link[stats]{median}}. Concepts: \link{mean_median}, \link{percentiles_quantiles}, \link{variance_sd}. Walkthrough: \code{ru_guide("mean_median")}.}
\references{Native help: \code{help("median", package="stats")}. \url{https://search.r-project.org/R/refmans/stats/html/00Index.html}}
\examples{
data(faithful)
x <- faithful$eruptions
median(x)
mean(x)
hist(x, breaks=10, xlab="Duration (minutes)")
}