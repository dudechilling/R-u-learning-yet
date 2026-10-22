\name{function_mean}
\alias{r_mean}
\alias{function_mean}
\concept{R function mean}
\title{mean() - Calculate an Arithmetic Average}
\description{\code{mean()} adds numeric values and divides by the number of usable observations. It answers "what is the arithmetic average of these recorded numbers?" The result is a single numerical summary. For a distribution with multiple clusters or strong outliers, that summary can be misleading on its own.}
\section{Syntax}{\preformatted{mean(x, trim = 0, na.rm = FALSE)}}
\section{Important arguments}{\code{x} is the numeric vector. \code{na.rm=FALSE} leaves missing values in place, so a missing measurement generally produces \code{NA}. \code{na.rm=TRUE} excludes missing values from the computation; you should report how many were excluded. \code{trim} removes a specified fraction of values from each end after sorting and is not the default arithmetic mean.}
\section{What it returns}{One numeric mean for the usable values. It is not a population inference unless the observation design supports one.}
\section{Common mistakes}{Do not average arbitrary category labels; R may report \code{NA} with a warning. If all observations are missing, the answer is not a meaningful measured average. A weighted mean requires valid weights and a different function, such as \code{weighted.mean()}.}
\section{Adapt the example}{Replace \code{faithful$waiting} with any suitable numerical column after checking \code{str(your_data)}. To calculate averages by category, use \code{tapply(values,group,mean)} or \code{aggregate()}. See the \code{group_means} walkthrough.}
\seealso{Native R documentation: \code{\link[base]{mean}}. Concepts: \link{mean_median}, \link{variance_sd}, \link{population_sample}. Walkthrough: \code{ru_guide("group_means")}.}
\references{Native help: \code{help("mean", package="base")}. \url{https://search.r-project.org/R/refmans/base/html/00Index.html}}
\examples{
data(faithful)
x <- faithful$waiting
mean(x)
mean(x, na.rm=TRUE)
# Replace x with your_data$numeric_column.
}