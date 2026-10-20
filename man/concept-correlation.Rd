\name{correlation}
\alias{correlation}
\alias{correlation_concept}
\alias{pearson_r}
\alias{linear_association}
\concept{Pearson correlation}
\concept{Spearman correlation}
\concept{association}
\concept{causation}
\title{Correlation and Linear Association}
\description{Correlation summarizes an association between two measured variables. Pearson's correlation coefficient, usually called \emph{r}, describes the direction and strength of a \emph{linear} association using values between minus one and one.}
\section{Explanation}{A positive Pearson r means that larger values of one variable tend to occur with larger values of the other along a straight-line pattern; a negative r means the opposite. A value near zero means little linear association, not necessarily no relationship. A curved or grouped pattern can have r near zero. The coefficient is unit-free, but still sensitive to outliers and to restricted measurement ranges. Plot paired observations before trying to interpret one coefficient.}
\section{Practical example}{The built-in \code{cars} dataset records speeds and stopping distances in paired rows. Plot stopping distance against speed, then compute Pearson's r. The dataset supports describing association among those records. It cannot by itself prove that changing speed causes a specific change in stopping distance under every condition.}
\section{Important distinctions}{\emph{Spearman's rho} is correlation of ranks and describes monotonic association; it does not require a straight-line relationship but also cannot capture every nonlinear pattern. \emph{Regression} models how an outcome varies with predictors and provides a slope in units. \emph{Correlation} is symmetric between two variables; an ordinary regression slope is not. Neither automatically establishes causation.}
\section{Limitations}{Correlations can arise from confounding, chance, selection effects or combining distinct groups. Missing paired observations must be removed together, not independently in each column. Statistical significance and the magnitude of correlation answer different questions.}
\section{R application}{Use \code{plot(x,y)} to inspect the shape, \code{cor(x,y)} to calculate a coefficient and \code{cor.test(x,y)} for a test under suitable assumptions. For rank-based association specify \code{method="spearman"}. Use column names that correspond to the same observations.}
\seealso{Related concepts: \link{mean_median}, \link{variance_sd}, \link{autocorrelation}, \link{hypothesis_tests_pvalues}, \link{independent_paired}. Native R help: \code{?cor}, \code{?cor.test}, \code{?plot}.}
\references{\url{https://search.r-project.org/R/refmans/stats/html/cor.html}

\url{https://www.itl.nist.gov/div898/handbook/eda/section3/eda35c.htm}}
\examples{
data(cars)
plot(cars$speed, cars$dist, pch=19,
     xlab="Speed", ylab="Stopping distance")
cor(cars$speed, cars$dist)
cor.test(cars$speed, cars$dist)
# A near-zero r would not rule out a curved association.
}