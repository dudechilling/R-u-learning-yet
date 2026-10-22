\name{confidence_intervals}
\alias{confidence_intervals}
\alias{confidence_interval}
\alias{confidence interval}
\alias{confidence_limits}
\concept{confidence interval}
\concept{confidence level}
\concept{sampling uncertainty}
\concept{interval estimate}
\title{Confidence Intervals and Estimation}
\description{A \emph{confidence interval} is an interval produced by a statistical procedure designed to contain a specified population parameter at a stated long-run rate under that procedure's assumptions. A 95-percent confidence procedure is intended to cover the fixed parameter in approximately 95 percent of repeated samples.}
\section{Explanation}{Sample estimates vary because selecting a different sample usually gives different results. An interval gives a range of parameter values compatible with the data and the chosen procedure, subject to sampling and model assumptions. For a mean with unknown population standard deviation, a common t interval uses the sample mean, standard error and a t critical value. A larger sample size often reduces uncertainty when the sampling design supports the formula, while more variable observations often widen the interval.}
\section{Practical example}{For the control observations in \code{PlantGrowth}, calculate a t confidence interval for the group's mean weight. Read the interval alongside the point estimate and the number of observations. To compare two independent groups, request a confidence interval for the \emph{difference of means}, not separate intervals interpreted by eye.}
\section{Important distinctions}{A 95-percent confidence interval is not a declaration that a \emph{fixed parameter has a 95-percent chance} of lying between these particular computed endpoints. The 95 percent refers to coverage across repeated samples. A \emph{prediction interval} concerns a future individual observation and commonly includes more uncertainty than an interval for the mean. A \emph{credible interval} is a different Bayesian concept with different assumptions.}
\section{Limitations}{An interval computed from a nonrepresentative sample does not repair the sampling bias. Invalid assumptions, unreported multiple analyses, measurement error and dependence can change coverage. Narrowness alone does not imply that an estimate is accurate or practically useful.}
\section{R application}{Use \code{t.test(x, conf.level=.95)$conf.int} for a t interval for one mean under suitable conditions. In \code{t.test(x,y)}, the interval is for the difference of population means according to the sample order. Read the direction before interpreting the sign.}
\seealso{Related concepts: \link{population_sample}, \link{sampling_distributions}, \link{variance_sd}, \link{hypothesis_tests_pvalues}, \link{independent_paired}. Native R help: \code{?t.test}, \code{?sd}, \code{?qt}.}
\references{\url{https://www.itl.nist.gov/div898/handbook/eda/section3/eda352.htm}

\url{https://itl.nist.gov/div898/handbook/prc/section1/prc14.htm}}
\examples{
data(PlantGrowth)
x <- subset(PlantGrowth, group=="ctrl")$weight
result <- t.test(x, conf.level=.95)
result$estimate
result$conf.int
# The interval's coverage depends on the sampling assumptions.
}