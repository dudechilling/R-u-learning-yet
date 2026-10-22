\name{function_table}
\alias{r_table}
\alias{function_table}
\concept{R function table}
\title{table() - Count Categories}
\description{\code{table()} counts how often each category or combination of categories appears in recorded observations. It is a descriptive count, not a frequency-weighted tally unless the supplied data have one row per actual observed unit.}
\section{Syntax}{\preformatted{table(..., useNA = "no")}}
\section{Important arguments}{Supply one or more aligned categorical vectors. \code{useNA} determines whether missing labels are included as a category. The default excludes missing labels; counting NAs explicitly can prevent silent denominator changes.}
\section{What it returns}{A table of frequencies. Use \code{prop.table()} to divide frequencies by the relevant total and get sample proportions, or \code{margin.table()} to aggregate a contingency table.}
\section{Common mistakes}{In an aggregated table, each row can represent many units with a frequency column; \code{table()} alone would count rows, not the original units. Do not infer a population probability from a convenient sample's frequencies.}
\section{Adapt the example}{Replace \code{iris$Species} with a category column and label the counted units. For a plot, use \code{barplot(table(x))} rather than \code{hist(x)}, which expects numeric intervals.}
\seealso{Native R documentation: \code{\link[base]{table}}. Concepts: \link{population_sample}, \link{probability_distributions}, \link{mean_median}. Walkthrough: \code{ru_guide("relative_frequency")}.}
\references{Native help: \code{help("table", package="base")}. \url{https://search.r-project.org/R/refmans/base/html/00Index.html}}
\examples{
data(iris)
count <- table(iris$Species)
count
prop.table(count)
barplot(count,ylab="Count",main="Recorded flower species")
}