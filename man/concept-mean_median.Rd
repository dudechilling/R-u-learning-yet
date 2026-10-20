\name{mean_median}
\alias{mean_median}
\alias{central_tendency}
\alias{average}
\concept{mean}
\concept{median}
\concept{arithmetic average}
\concept{typical value}
\title{Mean and Median}
\description{The arithmetic \emph{mean} adds numerical observations and divides by their count. The \emph{median} is the middle value after ordering observations, or the mean of the two middle values when the count is even. Both describe a center, but answer different questions.}
\section{Explanation}{The mean uses every observation's numerical size. An unusually large value pulls the mean upward, and an unusually small value pulls it downward. The median uses the ordering of observations and is less sensitive to extremes. Neither statistic automatically represents a typical individual when the data have separate clusters. A grouped comparison may be more informative than one pooled center.}
\section{Practical example}{In the built-in \code{faithful} dataset, the \code{waiting} column gives waiting times between geyser eruptions. Compute both summaries, then plot a histogram. The distribution includes clusters, so a single average conceals information about the pattern. When comparing categories, calculate a center within each group rather than quietly combining unlike observations.}
\section{Important distinctions}{A \emph{mode} is the most frequently observed value or category; it is not the same as mean or median. R's \code{mode()} describes how an object is stored, not its statistical mode. A \emph{weighted mean} assigns different importance or frequencies to observations and requires valid weights. Missing values must be handled explicitly; deleting them can introduce bias.}
\section{Limitations}{A mean is not meaningful for arbitrary labels. The median alone does not describe spread, skew or multiple clusters. Always identify units, data exclusions, and the population or sample being summarized. A difference between sample means is not a causal conclusion.}
\section{R application}{R provides \code{mean(x)}, \code{median(x)} and the \code{na.rm=TRUE} argument. Use \code{table()} for category counts and \code{tapply()} for simple group-specific means. Check \code{?mean} and \code{?median} for return values and argument details.}
\seealso{Related concepts: \link{population_sample}, \link{variance_sd}, \link{percentiles_quantiles}, \link{sampling_distributions}. Native R help: \code{?mean}, \code{?median}, \code{?hist}.}
\references{\url{https://search.r-project.org/R/refmans/base/html/mean.html}}
\examples{
data(faithful)
mean(faithful$waiting)
median(faithful$waiting)
hist(faithful$waiting, xlab="Waiting time (minutes)",
     main="Waiting time between eruptions")
# Adapt: replace faithful$waiting with another numeric column.
}