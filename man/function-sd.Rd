\name{function_sd}
\alias{r_sd}
\alias{function_sd}
\concept{R function sd}
\title{sd() - Sample Standard Deviation}
\description{\code{sd()} measures the spread of numerical observations around their sample mean. R uses the sample standard deviation convention with denominator \code{n - 1} before taking the square root. The result has the same units as the observations, unlike variance.}
\section{Syntax}{\preformatted{sd(x, na.rm = FALSE)}}
\section{Important arguments}{\code{x} is a numeric vector (or object supported by the method). \code{na.rm=TRUE} drops missing values. At least two usable numerical values are needed; otherwise the result is \code{NA} rather than a useful measure.}
\section{What it returns}{One nonnegative sample standard deviation in the original units. It is not a standard error and does not identify the reason for variability.}
\section{Common mistakes}{Do not call \code{sd(x)} the population standard deviation without checking whether \code{x} covers the full population and whether the denominator convention is appropriate. Do not confuse an outlying observation with invalid data. Report exclusions when \code{na.rm=TRUE} is used.}
\section{Adapt the example}{Replace \code{iris$Sepal.Length} with the numeric column of interest. Use \code{sd(x)/sqrt(length(x))} only for the estimated standard error of a mean under suitable sampling assumptions. See the variance and sampling-distributions articles.}
\seealso{Native R documentation: \code{\link[stats]{sd}}. Concepts: \link{variance_sd}, \link{sampling_distributions}, \link{population_sample}. Walkthrough: \code{ru_guide("sample_sd")}.}
\references{Native help: \code{help("sd", package="stats")}. \url{https://search.r-project.org/R/refmans/stats/html/00Index.html}}
\examples{
data(iris)
x <- iris$Sepal.Length
sd(x)      # centimetres
var(x)     # squared centimetres
sd(x)/sqrt(length(x))  # estimated mean SE under assumptions
}