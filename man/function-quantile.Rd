\name{function_quantile}
\alias{r_quantile}
\alias{function_quantile}
\concept{R function quantile}
\title{quantile() - Find Distribution Cutoffs}
\description{\code{quantile()} finds numerical cutoffs at requested cumulative proportions of an observed sample. For example, a 0.75 quantile is a sample 75th-percentile cutoff, not a theoretical normal-model cutoff.}
\section{Syntax}{\preformatted{quantile(x, probs = seq(0, 1, .25), na.rm = FALSE, type = 7)}}
\section{Important arguments}{\code{x} is numerical data. \code{probs} gives target proportions from 0 to 1; use \code{.75}, not \code{75}. \code{na.rm} controls missing-value removal. \code{type} chooses an interpolation convention; the default is 7. Several conventions give different results for small samples.}
\section{What it returns}{One or more numerical sample cutoffs, usually named by percentage. An interpolated cutoff may fall between two observed measurements.}
\section{Common mistakes}{Do not interpret the 75th-percentile cutoff as "75 percent of the values are equal to this value." If asked for the percentile rank of a known observation, it is a different question. A sample quantile need not estimate a population quantile well in a biased sample.}
\section{Adapt the example}{Substitute \code{mtcars$mpg} with your numerical column and set \code{probs} to the required proportion. Use \code{IQR(x)} to summarize the spread between Q1 and Q3.}
\seealso{Native R documentation: \code{\link[stats]{quantile}}. Concepts: \link{percentiles_quantiles}, \link{probability_distributions}, \link{variance_sd}. Walkthrough: \code{ru_guide("percentile_cutoff")}.}
\references{Native help: \code{help("quantile", package="stats")}. \url{https://search.r-project.org/R/refmans/stats/html/00Index.html}}
\examples{
data(mtcars)
quantile(mtcars$mpg, probs=c(.25,.5,.75))
quantile(mtcars$mpg, probs=.9)
IQR(mtcars$mpg)
}