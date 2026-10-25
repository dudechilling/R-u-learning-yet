\name{ru_workspace}
\alias{ru_workspace}
\title{Inspect the Three-Mode RU Workspace Selector}
\description{
Return the structured Learn, Analyze, or Reference workspace selection.
The W1 interface does not launch implemented Learning or Analyzing
applications.
}
\usage{
ru_workspace(mode = c("learn", "analyze", "reference"))
}
\arguments{
\item{mode}{Omit this argument to request the three-mode selector.
An explicitly supplied value must be exactly one of \code{"learn"},
\code{"analyze"}, or \code{"reference"}. \code{NULL}, a partial name,
a missing value, and a vector of choices are invalid. The vector in
the formal default is not selected when the argument is omitted.}
}
\details{
\code{ru_workspace()} uses the omitted-argument check to return a selector.
\code{ru_workspace("reference")} returns a structured catalogue result
from \code{ru_reference(query = NULL, open = FALSE)}, rather than opening
a Viewer. The Learn and Analyze choices currently report
\code{UNAVAILABLE} with reason \code{NOT_IMPLEMENTED}. Selecting a mode
does not execute R code, mark lesson progress, or qualify a statistical
method.

Invalid explicit mode values raise a \code{ru_invalid_argument} condition.
Existing \code{ru_home()} and \code{ru_plan()} are separate interfaces.
}
\value{
A \code{ru_workspace_result} list containing \code{schema_version},
\code{status}, \code{mode}, \code{choices}, \code{opened},
\code{capability_status}, \code{reason_code}, and \code{consumer}.
With no \code{mode}, \code{status} is \code{SELECTOR} and
\code{reason_code} is \code{CHOICE_REQUIRED}. The Reference choice has
status \code{CATALOGUE} and a nested \code{ru_reference_result} in
\code{consumer}; the other choices have status \code{UNAVAILABLE}.
\code{opened} is \code{FALSE} for these W1 routes.
}
\seealso{\code{\link{ru_reference}}, \code{\link{ru_capabilities}},
\code{\link{ru_home}}}
\examples{
selector <- ru_workspace()
selector$status
selector$choices
reference <- ru_workspace("reference")
reference$consumer$status
}
