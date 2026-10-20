\name{sampling_distributions}
\alias{sampling_distributions}
\alias{sampling_distribution}
\alias{sampling distribution}
\alias{standard_error_concept}
\concept{sampling distribution}
\concept{standard error}
\concept{central limit theorem}
\concept{repeated samples}
\title{Sampling Distributions and Standard Error}
\description{Repeated samples from one population usually give different sample averages. The distribution of those averages is their sampling distribution. The standard error describes, or estimates, how much an estimated average would change from sample to sample.}
\section{Explanation}{Imagine repeatedly selecting the same number of units from a defined population, then calculating an average for each new sample. Those averages vary even if the population never changes. Their distribution is not the distribution of individual observations. Larger random samples commonly produce more precise means. Under suitable independent-sampling conditions, the standard error of a sample mean is estimated by the sample standard deviation divided by the square root of sample size. The central limit theorem provides an approximation to the distribution of means under its conditions, but not for every sample size or dependence pattern.}
\section{Practical example}{The included \code{iris} measurements can support a clearly labeled bootstrap demonstration: draw samples \emph{with replacement} from the recorded sepal lengths and calculate an average for each draw. This estimates resampling variability conditional on the empirical dataset. It cannot make the original records representative of every flower.}
\section{Important distinctions}{An individual-observation \emph{standard deviation} describes spread among observations. A \emph{standard error} describes uncertainty in an estimated statistic. A \emph{sample distribution} plots the sampled individual values; a \emph{sampling distribution} plots statistics from repeated samples. A bootstrap approximates sampling variability by resampling the available data and inherits its selection limitations.}
\section{Limitations}{Dependence, cluster sampling, selection bias and systematic missingness can invalidate the simple standard-error formula. Seeing a bell-shaped bootstrap histogram does not establish that the original sample is unbiased or that a theoretical central limit theorem applies to unrelated data.}
\section{R application}{For a simple sample mean use \code{sd(x)/sqrt(length(x))} when the sampling assumptions fit. For a bootstrap demonstration use \code{replicate()} and \code{sample(x, replace=TRUE)}. Distinguish the two computations; state the resample size and count.}
\seealso{Related concepts: \link{population_sample}, \link{variance_sd}, \link{mean_median}, \link{confidence_intervals}, \link{probability_distributions}. Native R help: \code{?sd}, \code{?sample}, \code{?replicate}.}
\references{\url{https://www.itl.nist.gov/div898/handbook/prc/section1/prc14.htm}}
\examples{
data(iris)
x <- iris$Sepal.Length
sd(x)/sqrt(length(x))  # simple-sample mean standard error
set.seed(12)
boot <- replicate(200, mean(sample(x, length(x), replace=TRUE)))
sd(boot)                 # bootstrap estimated standard error
# Resampling does not make these flowers a random population sample.
}