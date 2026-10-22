\name{probability_distributions}
\alias{probability_distributions}
\alias{distributions}
\alias{random_variable}
\alias{probability distribution}
\concept{discrete distribution}
\concept{continuous distribution}
\concept{random variable}
\title{Probability Distributions and Random Variables}
\description{A random variable assigns a numerical outcome to an uncertain process. Its \emph{probability distribution} describes which outcomes are possible and how probability is distributed among them. A distribution is a model of variation, not merely a list of measurements.}
\section{Explanation}{A discrete variable takes countable outcomes, such as a number of successes, with probabilities that sum to one. A continuous model assigns probability to intervals, not exact individual points: the area under a density curve over an interval gives probability. Parameters specify a particular distribution, such as a normal model's mean and standard deviation or a binomial model's number of trials and success probability. Before using any distribution, identify which assumptions are realistic for the process being studied.}
\section{Practical example}{Imagine counting how many of ten independent test items pass a check. If each has the same probability of passing, a binomial distribution can model the count. For a continuous example, an assumed normal model might describe a measurement with a specific mean and standard deviation. Neither assumption follows automatically from the existence of a numeric dataset.}
\section{Important distinctions}{A \emph{frequency distribution} describes observed records. A \emph{probability distribution} assigns model probabilities to possible outcomes, including unobserved outcomes. The height of a continuous density is not a probability at that exact value; integrate its area. An empirical proportion can inform a model parameter but does not demonstrate independence or identical chances on future trials.}
\section{Limitations}{No distribution family fits every dataset. A normal curve can miss outliers or multiple clusters. A binomial model is unsuitable when the trial outcomes are not independent, the number of trials varies, or the success probability changes. Model probabilities are conditional on the model being an acceptable description.}
\section{R application}{R's \code{d*} functions return probability mass or density, \code{p*} functions cumulative probability, \code{q*} functions quantiles and \code{r*} functions random draws. Examples include \code{dbinom()}, \code{pnorm()}, \code{qnorm()} and \code{rnorm()}. Consult their native help pages for parameter definitions.}
\seealso{Related concepts: \link{percentiles_quantiles}, \link{sampling_distributions}, \link{population_sample}, \link{confidence_intervals}. Native R help: \code{?dbinom}, \code{?pbinom}, \code{?pnorm}, \code{?qnorm}, \code{?rnorm}.}
\references{\url{https://search.r-project.org/R/refmans/stats/html/Normal.html}

\url{https://search.r-project.org/R/refmans/stats/html/Binomial.html}}
\examples{
dbinom(3, size=10, prob=.3)           # exactly 3 successes
pbinom(4, size=10, prob=.3)           # at most 4 successes
pnorm(85, mean=100, sd=15)           # left-tail area
qnorm(.9, mean=100, sd=15)           # modeled percentile
# The values here define hypothetical models, not recorded data.
}