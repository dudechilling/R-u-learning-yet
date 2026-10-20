\name{ru_open}
\alias{ru_open}
\title{Open a Local Concept, Function or Walkthrough Reference}
\description{Open the most relevant installed reference using ordinary R help for a concept or function, or the packaged guide for a walkthrough. Search and access do not require a network connection or Quarto installation.}
\usage{
ru_open(query, type = NULL)
}
\arguments{
\item{query}{A full question, partial phrase, or exact reference ID.}
\item{type}{Optional \code{"concept"}, \code{"function"} or \code{"walkthrough"} filter.}
}
\details{Use \code{ru_find()} to inspect all relevant results and copy the shown command. Concept and function articles are standard \code{.Rd} help pages displayed by \code{help()}; built-in R functions retain their own official documentation (for example \code{?sd}). Walkthroughs come from one canonical packaged Quarto file, also available as an editable standalone R script with \code{ru_edit()}. For established methods \code{ru_apply()} remains available but is not required for learning or running the native code.}
\seealso{\code{\link{ru_find}}, \code{\link{ru_guide}}, \link{stationarity}, \link{variance_sd}, \link{r_sd}, \link{r_hist}, \link{hypothesis_tests_pvalues}}
\examples{
# Search from ordinary language:
results <- ru_find("How does the sd function work?",n=2L)
stopifnot(nrow(results)>=1L)
# Open the native installed Help page in interactive R:
if (interactive()) ru_open("stationarity")
}