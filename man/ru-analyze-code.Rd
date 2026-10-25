\name{ru_analyze_code}
\alias{ru_analyze_code}
\title{Preview Inspectable R Code Without Executing It}
\description{
Produce a readable ordinary R code preview for an intact, eligible
\code{describe.numeric} plan. Generating code neither executes the
analysis nor confirms the plan against new data.
}
\usage{
ru_analyze_code(plan)
}
\arguments{
\item{plan}{An unmodified \code{READY} \code{ru_analysis_plan}
returned by \code{ru_analyze_plan()}. Non-ready or altered plans
are refused.}
}
\details{
The preview reads its outcome from a \code{data} object at evaluation
time; raw observations are not embedded. It shows numeric summary
steps, and for a histogram operation includes explicit bin endpoints
and the separately specified right-closed or left-closed convention.
The text is inspectable native R, not code that this call evaluates.

Previewing does not record a Run confirmation, verify the caller's
current frame, or produce exportable results. The caller must
revalidate through \code{ru_analyze_execute()} with an explicit
\code{confirm = TRUE}. An unmodified plan is necessary but not
sufficient for execution.
}
\value{
For a verified ready plan, a list with
\code{status = "PREVIEW_ONLY"}, \code{reason = "NOT_EXECUTED"},
\code{plan_id}, and one \code{code} string.
For a non-ready or modified plan, a list with
\code{status = "UNAVAILABLE"},
\code{reason = "PLAN_NOT_READY_OR_MODIFIED"}, and
\code{code = NULL}. No analysis result is returned.
}
\seealso{\code{\link{ru_analyze}}, \code{\link{ru_analyze_plan}},
\code{\link{ru_analyze_execute}}, \code{\link{ru_analyze_export}}}
\examples{
not_ready <- ru_analyze_plan(list())
ru_analyze_code(not_ready)$status
\dontrun{
# For an actual READY plan produced by ru_analyze_plan():
preview <- ru_analyze_code(plan)
if (identical(preview$status, "PREVIEW_ONLY")) cat(preview$code)
# This only displays code. It does not execute or confirm it.
}
}