\name{population_sample}
\alias{population_sample}
\alias{population}
\alias{sample_population}
\concept{population}
\concept{sample}
\concept{census}
\concept{sampling frame}
\title{Population and Sample}
\description{A \emph{population} is the full set of units about which a question seeks an answer. A \emph{sample} is the subset actually observed. A population does not have to be every person in a country: it can be all trees in one park, all transactions during a month, or all measurements from a defined process.}
\section{Explanation}{Begin by stating which units count, where and when they belong, and what is measured. A parameter, such as the population mean, describes that defined population. A statistic, such as the average of sampled values, describes the observations you have. We use sample statistics to learn about unobserved units, but the leap from a sample to its population depends on how observations were selected, what was missing, and whether they represent the target. A convenient sample can be described accurately without supporting a broader estimate.}
\section{Practical example}{Imagine trying to describe body size for a defined group of penguins at a field site. Individual records in a dataset are the observed sample; the population would need its own boundary, such as all penguins of the relevant species at that site during a specified period. The \code{iris} dataset likewise contains recorded flowers; it does not establish that those records were randomly sampled from every iris flower.}
\section{Important distinctions}{A \emph{census} tries to observe every unit in the defined population. A \emph{sampling frame} is the list or mechanism from which sampled units can actually be selected; it may fail to cover the target population. \emph{Sample size} is a count, not a guarantee of representativeness. Random selection can reduce selection bias, but does not automatically repair inaccurate measurements or missing data.}
\section{Limitations}{A result computed correctly from 50 observations is still a result about those 50 observations unless the design supports generalization. Do not invent a population when the question provides only a dataset. Distinguish biological, geographical and time boundaries before interpreting percentages or uncertainty.}
\section{R application}{Use \code{nrow()} to count recorded cases; \code{mean()} summarizes a numeric sample. \code{sample()} selects from an explicitly supplied list but cannot make the original list representative of units absent from it.}
\seealso{Related concepts: \link{mean_median}, \link{sampling_distributions}, \link{confidence_intervals}, \link{independent_paired}. Native R help: \code{?mean}, \code{?sample}.}
\references{\url{https://www.itl.nist.gov/div898/handbook/prc/section1/prc14.htm}}
\examples{
data(iris)
nrow(iris)                 # recorded flowers, not all flowers
mean(iris$Sepal.Length)    # sample description
table(iris$Species)        # observations per recorded species
}