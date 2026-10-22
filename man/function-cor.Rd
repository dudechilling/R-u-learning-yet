\name{function_cor}
\alias{r_cor}
\alias{function_cor}
\concept{R function cor}
\title{cor() - Measure Association}
\description{\code{cor()} calculates correlation between paired numeric variables. Pearson's coefficient summarizes the direction and strength of their linear relationship. It cannot determine causation, and a coefficient near zero does not exclude a curved relationship.}
\section{Syntax}{\preformatted{cor(x, y, use = "everything", method = "pearson")}}
\section{Important arguments}{\code{x} and \code{y} are aligned measurements: one x and one y per row. \code{method} can be \code{"pearson"} for linear correlation or \code{"spearman"} for rank-based monotonic association. \code{use} specifies missing-value handling, such as \code{"complete.obs"}. Inspect how many pairs were excluded.}
\section{What it returns}{One coefficient between minus one and one for two vectors, or a correlation matrix if supplied suitable multivariate data. This value is not a test p-value; use \code{cor.test()} for an appropriate significance test.}
\section{Common mistakes}{Do not independently delete NAs in x and y: this can break row alignment. Do not divide by zero or interpret a correlation for a constant variable. Plot the pairs to find curves, unusual observations and separate subgroups.}
\section{Adapt the example}{Replace \code{cars$speed} and \code{cars$dist} with aligned numeric columns. Change the method only if the scientific question matches that association concept.}
\seealso{Native R documentation: \code{\link[stats]{cor}}. Concepts: \link{correlation}, \link{autocorrelation}, \link{hypothesis_tests_pvalues}. Walkthrough: \code{ru_guide("correlation_test")}.}
\references{Native help: \code{help("cor", package="stats")}. \url{https://search.r-project.org/R/refmans/stats/html/00Index.html}}
\examples{
data(cars)
plot(cars$speed,cars$dist,pch=19,
     xlab="Speed",ylab="Stopping distance")
cor(cars$speed,cars$dist)
cor(cars$speed,cars$dist,method="spearman")
}