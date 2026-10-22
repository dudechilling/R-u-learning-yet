\name{function_hist}
\alias{r_hist}
\alias{function_hist}
\concept{R function hist}
\title{hist() - Create a Histogram}
\description{\code{hist()} groups numerical observations into intervals and draws their frequencies or densities. The horizontal axis represents the measured numeric variable; the vertical axis depends on whether the plot shows frequency counts or density. Inspect the bin edges rather than treating the resulting bars as exact-value probabilities.}
\section{Syntax}{\preformatted{hist(x, breaks = "Sturges", freq = NULL, col = "lightgray",
     main = NULL, xlab = NULL, ylab = NULL, ...)}}
\section{Important arguments}{\code{x} selects numerical observations; \code{breaks} chooses interval boundaries or an approximate number of intervals, depending on form; \code{col} sets bar colour; \code{main} sets the title; \code{xlab} and \code{ylab} label the axes. For non-equidistant bins, use density rather than raw counts when comparing bar areas. Use \code{plot=FALSE} to return the histogram data without drawing a plot.}
\section{What it returns}{A histogram object with \code{breaks}, \code{counts}, \code{density} and \code{mids}. You can use these components to annotate bars with \code{text()} or to inspect the number of observations in each bin.}
\section{Common mistakes}{Do not pass a character category column to \code{hist()}: use \code{table()} and \code{barplot()} instead. Repeatedly changing the bin width can create or hide visual features. The argument \code{breaks=10} suggests a number of intervals rather than guaranteeing exactly ten bins.}
\section{Adapt the example}{Replace \code{faithful$eruptions} with your own numeric column and update the title, units and \code{breaks}. Use \code{abline(v=mean(x))} to mark a reference value and \code{legend()} to explain it. For a complete editable example, call \code{ru_edit("histogram")}.}
\seealso{Native R documentation: \code{\link[graphics]{hist}}. Concepts: \link{mean_median}, \link{variance_sd}, \link{probability_distributions}. Walkthrough: \code{ru_guide("histogram")}.}
\references{Native help: \code{help("hist", package="graphics")}. \url{https://search.r-project.org/R/refmans/graphics/html/00Index.html}}
\examples{
data(faithful)
x <- faithful$eruptions
h <- hist(x, breaks=10, col="lightblue",
          main="Eruption durations",
          xlab="Duration in minutes",
          ylab="Number of eruptions")
print(h$counts)
abline(v=mean(x), col="blue", lwd=2)
legend("topright", legend="Mean", col="blue", lty=1, bty="n")
}