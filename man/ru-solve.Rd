\name{ru_solve}
\alias{ru_solve}
\title{Solve Supported Statistical Questions with a Guided Local Walkthrough}
\description{
Interpret a statistical question using RU's deterministic supported methods,
compute theoretical results when sufficient inputs are provided, and prepare
a beginner-friendly local guide with R code to inspect and run.
}
\usage{
ru_solve(question, open = TRUE, level = c("beginner", "concise"))
}
\arguments{
\item{question}{One nonmissing, nonempty character string describing a
statistical question. Include the relevant parameters and model conditions.
The text is not evaluated as R code.}
\item{open}{One nonmissing logical value. If \code{TRUE}, attempt to show the
guide in the RStudio Viewer when available. \code{FALSE} does not launch
the Viewer; structured guidance is still returned.}
\item{level}{Instructional detail: \code{"beginner"} or \code{"concise"}.
The default is \code{"beginner"}.}
}
\details{
The first fully computed problem family is the sum of two fair, independent,
ordinary dice with specified numbers of faces. Supported requests include
the probability mass function (PMF), cumulative distribution (CDF),
expected value, random-variable variance, and supported event probabilities.
The assumption of independent, equally likely faces describes a theoretical
model, not an observation about a real die.

A short conceptual question, for example \code{"PMF"}, may produce
\code{GUIDED_REFERENCE}: an explanation that does not invent dice or
parameters. \code{NEEDS_INPUT} means additional model inputs are necessary;
\code{UNSUPPORTED} means the method or specified model is outside the
validated computation. \code{INVALID} identifies invalid input.
No numerical answer is asserted for these statuses.

For a \code{SOLVED} question, the theoretical answer is computed locally
by RU. The guide's example R code is a text preview, \emph{not} evidence
that the student has run that code in their R session. Generated guidance
and any resulting temporary HTML are local; the question is not sent to
a remote AI service and no result is automatically published or exported.
The local Viewer page has a keyboard-operable Copy R code button. Copying
places the displayed source text on the clipboard when permitted; it does
not execute the text. If clipboard access is unavailable, students can
select and copy the preview manually.

Viewer launch availability depends on the actual interactive RStudio
capability. A prepared page or installed source alone does not establish
that the Viewer opened successfully.

Use \code{ru_find()} to discover installed reference topics by keyword.
Use \code{ru_solve()} to interpret an actual question and obtain a guided
worked solution where the model is supported. Existing ordinary
\code{ru_find()} search results remain a data frame.
}
\value{
A structured \code{ru_solution} result describing status, question, inputs,
requested outputs, theoretical answer when solved, instructional guide,
R code preview, and whether the Viewer actually opened. Non-solved statuses
carry appropriate reasons rather than invented numeric results.
}
\seealso{\code{\link{ru_find}}, \code{\link{ru_reference}},
\code{\link{ru_capabilities}}}
\examples{
ru_solve("PMF", open = FALSE)
}
