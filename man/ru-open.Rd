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
\details{Inside RStudio, concept and function entries open using native
R Help; the Help pane preserves RStudio's own navigation history.
A selected walkthrough displays as a formatted temporary Rd topic using
the existing \code{rstudioapi::previewRd()} integration when available.
The text comes from the installed canonical Quarto guide, so no second
copy of the lesson is maintained. Outside RStudio, the same references
use readable Console text. When there is no suitable topic, a no-match
message appears rather than an unrelated statistical method.
Legacy \code{ru_apply()} examples remain compatible but are not
substitutes for learning ordinary R functions.}
\seealso{\code{\link{ru_find}}, \code{\link{ru_guide}}, \link{stationarity}, \link{variance_sd}, \link{r_sd}, \link{r_hist}, \link{hypothesis_tests_pvalues}}
\examples{
# Search from ordinary language:
results <- ru_find("How does the sd function work?",n=2L)
stopifnot(nrow(results)>=1L)
# Open the native installed Help page in interactive R:
if (interactive()) ru_open("stationarity")
}