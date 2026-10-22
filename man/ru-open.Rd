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
\details{
\code{ru_open()} opens a compact local HTML reference page in the
RStudio Viewer when present, otherwise an honest summary indicating
the existing native Help article or older walkthrough. The returned
metadata are invisible. Native R documentation remains available using
\code{help(topic,package="rulearn")} and base R \code{?function}.
No additional application or online service is started.
}
\seealso{\code{\link{ru_find}}, \code{\link{ru_guide}}, \link{stationarity}, \link{variance_sd}, \link{r_sd}, \link{r_hist}, \link{hypothesis_tests_pvalues}}
\examples{
# Search from ordinary language:
results <- ru_find("How does the sd function work?",n=2L)
stopifnot(nrow(results)>=1L)
# Open the native installed Help page in interactive R:
if (interactive()) ru_open("stationarity")
}