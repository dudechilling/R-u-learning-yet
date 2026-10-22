\name{function_t_test}
\alias{r_t_test}
\alias{function_t_test}
\concept{R function t.test}
\title{t.test() - Compare Means with Uncertainty}
\description{\code{t.test()} performs a one-sample, paired or two-independent-sample t-test depending on which arguments are supplied. The result includes mean estimates, a test statistic, a p-value, and a confidence interval. The correct form depends on the study design, not merely the number of columns.}
\section{Syntax}{\preformatted{t.test(x, y = NULL, alternative = "two.sided",
       mu = 0, paired = FALSE, var.equal = FALSE, conf.level = .95)}}
\section{Important arguments}{\code{x} is a numeric sample. With \code{y=NULL}, \code{mu} specifies the reference mean. With two independent groups, supply \code{y} and leave \code{paired=FALSE}; by default R uses Welch's unequal-variance approach. Set \code{paired=TRUE} only when observations truly match by subject. \code{alternative} chooses \code{"less"}, \code{"greater"} or \code{"two.sided"}; direction depends on sample order. \code{conf.level} uses a probability such as \code{.95}.}
\section{What it returns}{An \code{htest} object containing estimates, a confidence interval, the t statistic and degrees of freedom, and a p-value. It does not certify the assumptions or establish causation.}
\section{Common mistakes}{Two equal-length vectors are not necessarily paired. Reversing sample order reverses a directional test. Treating a p-value as the probability that the null hypothesis is true is incorrect. Check independence, outliers, and sample size before interpreting the inferential result.}
\section{Adapt the example}{Use the \code{PlantGrowth} control and treatment observations as two independent samples only when their design justifies it. For the \code{sleep} data, first match records by subject ID, then use \code{paired=TRUE}.}
\seealso{Native R documentation: \code{\link[stats]{t.test}}. Concepts: \link{hypothesis_tests_pvalues}, \link{confidence_intervals}, \link{independent_paired}. Walkthrough: \code{ru_guide("two_sample_t")}.}
\references{Native help: \code{help("t.test", package="stats")}. \url{https://search.r-project.org/R/refmans/stats/html/00Index.html}}
\examples{
data(PlantGrowth)
a <- subset(PlantGrowth,group=="ctrl")$weight
b <- subset(PlantGrowth,group=="trt1")$weight
fit <- t.test(a,b,var.equal=FALSE,conf.level=.95)
fit$estimate
fit$conf.int
fit$p.value
}