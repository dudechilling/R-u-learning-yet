\name{independent_paired}
\alias{independent_paired}
\alias{paired_observations}
\alias{independent_groups}
\alias{paired versus independent}
\concept{independent samples}
\concept{paired data}
\concept{matched pairs}
\concept{repeated measurements}
\title{Independent and Paired Observations}
\description{\emph{Independent} observations do not share an unmodeled relationship that makes one value predict another through the sampling design. \emph{Paired} observations are deliberately linked, such as two measurements on the same participant or matched experimental units. The analysis must respect that link.}
\section{Explanation}{Start with the units being measured, not the appearance of the columns. When two groups contain different, independently selected units, their observations may support an independent-group comparison. When the same unit is measured before and after an event, the natural unit of analysis is each unit's difference. The choice changes the variability calculation, the appropriate test, and often the precision. Two columns of the same length are not proof of pairing. Rows must be matched by an actual identifier.}
\section{Practical example}{R's built-in \code{sleep} data contain measurements from the same people across two treatment conditions. Use the ID column to match each subject's records and compute differences. The \code{PlantGrowth} control and treatment observations illustrate a separate-group comparison. These are distinct designs, even if both contain two columns of numbers.}
\section{Important distinctions}{\emph{Paired} does not mean that the sample sizes merely happen to match. \emph{Independent} does not mean that subjects differ in every characteristic; it is an assumption about dependence of observations. \emph{Repeated measures} with more than two time points may need methods beyond a paired t-test. Comparing groups within clusters can also require a model that recognizes cluster dependence.}
\section{Limitations}{A paired t-test applied to incorrectly matched values can produce a misleading result. An independent t-test on repeated measures can underestimate or misstate uncertainty. Neither test establishes a causal interpretation without a suitable design. If dependence is unknown, stop and investigate the records before choosing a test.}
\section{R application}{For matched data use \code{t.test(after, before, paired=TRUE)} with rows matched by ID. For genuinely independent groups, use \code{t.test(x,y,paired=FALSE)}; by default R uses Welch's unequal-variance version. Report the order and units of any differences.}
\seealso{Related concepts: \link{population_sample}, \link{hypothesis_tests_pvalues}, \link{confidence_intervals}, \link{correlation}. Native R help: \code{?t.test}, \code{?merge}.}
\references{\url{https://www.itl.nist.gov/div898/handbook/eda/section3/eda352.htm}}
\examples{
data(sleep)
before <- subset(sleep, group==1, select=c(ID,extra))
after <- subset(sleep, group==2, select=c(ID,extra))
matched <- merge(before, after, by="ID", suffixes=c("_1","_2"))
stopifnot(nrow(matched)==length(unique(matched$ID)))
t.test(matched$extra_2, matched$extra_1, paired=TRUE)
# Match by ID; do not assume input row positions are aligned.
}