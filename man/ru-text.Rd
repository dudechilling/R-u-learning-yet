\name{ru_text}
\alias{ru_text}
\title{Show a Short Offline Reference in an R Terminal}
\description{Explicitly print a short, readable reference answer and native
R code when RStudio's Viewer pane is unavailable or undesired.
Ordinary search and guide calls remain silent by default.}
\usage{
ru_text(query)
}
\arguments{
\item{query}{Plain-language question, reference ID, or search phrase.}
}
\details{Uses the same installed source as the compact Viewer reference.
No network connection, local server or Quarto installation is needed.
The return value contains matching reference metadata invisibly.}
\seealso{\link{ru_find},\link{ru_open},\link{ru_guide}}
\examples{
ru_text("What is positive skew?")
}
