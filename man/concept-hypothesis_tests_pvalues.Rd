\name{hypothesis_tests_pvalues}
\alias{hypothesis_tests_pvalues}
\alias{hypothesis_test}
\alias{p_value}
\alias{p-value}
\alias{significance_test}
\concept{hypothesis test}
\concept{null hypothesis}
\concept{alternative hypothesis}
\concept{p-value}
\concept{statistical significance}
\title{Hypothesis Tests and P-values}
\description{A \emph{hypothesis test} compares observed data with a statistical model that includes a stated \emph{null hypothesis}. A \emph{p-value} is the probability, under that null model and its assumptions, of obtaining a test statistic at least as extreme as the one observed in the direction specified by the test.}
\section{Explanation}{Before calculating, state the null and alternative claims, select a statistic, and check the sampling or experimental design. The p-value helps describe how incompatible the observed result is with the specified model. The direction matters: a two-sided test asks about differences in either direction, while a one-sided test asks about one specified direction. A smaller p-value can indicate a greater mismatch with the null model, but cannot by itself tell whether a difference is useful, large, causal, or important. Report the estimate, an interval when suitable, and the study context rather than relying only on a threshold.}
\section{Practical example}{The built-in \code{PlantGrowth} data contain numerical weights for a control group and treatments. To compare the control with treatment 1, first check that the groups represent independent units, then calculate sample means and use a Welch two-sample t-test under suitable conditions. The test does not independently validate the experimental design.}
\section{Important distinctions}{The null hypothesis is not automatically a belief that \emph{nothing happens}. It is a specific statistical claim used in a model. A p-value of 0.03 does \emph{not} mean a three-percent probability that the null is true, or that random chance alone caused the difference. Failure to find a small p-value is not proof of no difference. \emph{Statistical significance} does not determine \emph{practical significance}.}
\section{Limitations}{Invalid independence or distribution assumptions can make p-values misleading. Testing many possibilities and reporting only favorable results also changes what a small p-value means. A two-sided result should not be reinterpreted as a pre-specified one-sided result after looking at the data. Tests do not demonstrate causation by themselves.}
\section{R application}{R provides \code{t.test(x, y, alternative="two.sided")} for suitable independent numeric groups, \code{paired=TRUE} for genuine matched observations, and \code{cor.test()} for suitable association questions. Inspect returned estimates and confidence limits; do not report only \code{p.value}.}
\seealso{Related concepts: \link{independent_paired}, \link{confidence_intervals}, \link{population_sample}, \link{correlation}, \link{sampling_distributions}. Native R help: \code{?t.test}, \code{?cor.test}.}
\references{\url{https://www.amstat.org/asa/files/pdfs/p-valuestatement.pdf}

\url{https://www.itl.nist.gov/div898/handbook/eda/section3/eda352.htm}}
\examples{
data(PlantGrowth)
a <- subset(PlantGrowth, group=="ctrl")$weight
b <- subset(PlantGrowth, group=="trt1")$weight
mean(a); mean(b)
out <- t.test(a, b, alternative="two.sided")
out$estimate
out$conf.int
out$p.value
# The test does not establish why the groups differ.
}