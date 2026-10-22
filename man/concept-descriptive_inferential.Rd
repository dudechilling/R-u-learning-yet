\name{descriptive_inferential}
\alias{descriptive_inferential}
\alias{descriptive_statistics}
\alias{inferential_statistics}
\concept{descriptive statistics}
\concept{inferential statistics}
\concept{describe vs infer}
\title{Descriptive and Inferential Statistics}
\description{Descriptive statistics tell you what the observations in a dataset show. Inferential statistics use data from a sample to estimate or test claims about a larger, defined population. Inference requires additional assumptions about how the observations were obtained.}
\section{Explanation}{
A \emph{sample} is the set of cases measured; the \emph{population} is the wider set you want to know about. A \emph{statistic} is a number calculated from sample data, such as an average, count or percentage. A \emph{parameter} is a number describing the population, which usually cannot be measured directly.

Reporting that the median of your recorded measurements is 3 centimetres is \emph{descriptive}. Estimating the unknown median of all relevant units from a defensible sample is \emph{inferential}. Running a test does not automatically make the inference sound: the sampling process, dependence and assumptions determine whether a population claim is justified.

Charts and tables are descriptive tools even when they later help with inference. Some tasks ask only to characterize the available data. Do not run a hypothesis test merely because R makes it possible.
}
\section{Practical example}{
The built-in \code{iris} data contain 150 recorded flowers. \code{nrow(iris)}, \code{table(iris$Species)} and \code{mean(iris$Sepal.Width)} describe those records. They cannot, without additional sampling evidence, establish the average for every iris flower in a region. An interval or significance test would add modeling assumptions, not automatically repair that missing design.
}
\section{Important distinctions}{
\emph{Description} concerns recorded observations; \emph{inference} concerns a wider target population or model parameter. \emph{Prediction} concerns unknown or future outcomes and is not identical to either. Machine learning can be used to describe, classify or predict, but mentioning a predictive algorithm does not make a result representative or causal. A \emph{census} aims to observe all population units and has different coverage concerns.
}
\section{Limitations}{
A beautifully labeled histogram cannot establish representativeness or causation. A small p-value is not the probability that the null hypothesis is true. A missing population definition makes general claims unclear even when all R calculations are numerically correct.
}
\section{R application}{
For a description use \code{summary()}, \code{mean()}, \code{median()}, \code{table()}, \code{hist()} or \code{boxplot()} on appropriate variables. For inference, choose an appropriate method only \emph{after} establishing the design and assumptions. See \code{?t.test} and \code{?cor.test} for R's inferential functions, but do not use them automatically.
}
\seealso{\link{population_sample}, \link{mean_median}, \link{variance_sd}, \link{sampling_distributions}, \link{hypothesis_tests_pvalues}, \link{confidence_intervals}}
\references{
\url{https://www.itl.nist.gov/div898/handbook/prc/section1/prc14.htm}

\url{https://www.amstat.org/asa/files/pdfs/p-valuestatement.pdf}
}
\examples{
data(iris)
nrow(iris)                # number of recorded flowers
table(iris$Species)       # recorded categories
mean(iris$Sepal.Width)   # descriptive sample average, in cm
# These commands alone do not estimate all unobserved flowers.
}