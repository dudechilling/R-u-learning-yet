\name{ru_analyze_export}
\alias{ru_analyze_export}
\title{Export a Descriptive Result or an Unexecuted Code Preview}
\description{
Request a restricted local export from a ready
\code{describe.numeric} plan. This low-level routine requires a fresh,
destination-specific authorization object; an ordinary path string is
not accepted as user consent.
}
\usage{
ru_analyze_export(plan, result = NULL, path, include_data = FALSE, data = NULL)
}
\arguments{
\item{plan}{An unchanged, sealed, \code{READY}
\code{ru_analysis_plan}.}
\item{result}{\code{NULL} for guarded code-only export, or a verified
\code{SUCCEEDED} \code{ru_analysis_result} bound to the exact plan.}
\item{path}{A fresh, one-shot
\code{ru_analysis_export_destination} object for the requested local
file, issued by an authorized caller after an affirmative
destination-specific action. A character filename is not a valid
authorization. The helper that currently constructs this object
is private; this documentation does not claim that a working public
human-consent UI exists.}
\item{include_data}{One nonmissing logical, default \code{FALSE}.
Raw-data export with \code{TRUE} is unsupported and refused.}
\item{data}{For result-bound export, the \emph{current} frame or
\code{list(data = current_frame, source_context = current_record)}
when the plan recorded source metadata. Omission is refused for a
result export. For guarded code-only export the current frame is not
treated as verified execution.}
}
\details{
Exports are separate from eligibility, preview, and confirmed
execution. The destination authorization is consumed upon the first
attempt, including a refused attempt; retry requires a new
affirmative action. The function verifies the ready plan, destination
scope, result seal and current data binding, refuses raw rows, and
does not overwrite an existing destination. It also rejects invalid
or unwritable paths. Collision handling is fail-closed but concurrent
file-creation exclusivity has not been qualified on every filesystem.

With \code{result = NULL}, any permitted code-only file is visibly
marked \code{NOT_EXECUTED}; it includes a protective stop before
illustrative R code and is not a verified analysis. With a valid
successful result, only derived numeric summaries and optional
histogram bin information are written. \code{FAILED} or
\code{CANCELLED} outcomes do not qualify as successful results.

The question-first Shiny consumer has a local destination field,
affirmative export checkbox, and explicit Export action. These are
implemented UI controls, not evidence of user-comprehension or human
consent testing. The internal one-shot authorization helper is private,
not a stand-alone public consent interface. No completed Windows,
accessibility, privacy, or real-browser qualification is asserted.
}
\value{
A list with \code{status} and \code{reason}.
\code{status = "EXPORTED"} includes \code{reason =
"CODE_ONLY_NOT_EXECUTED"} or \code{"BOUND_RESULT"}, the
local \code{path}, and \code{plan_id}. Refusals return
\code{status = "REFUSED"} and a reason such as
\code{FRESH_EXPORT_CONSENT_REQUIRED},
\code{CURRENT_DATA_REQUIRED},
\code{RESULT_NOT_EXPORTABLE},
\code{REVALIDATION_REQUIRED}, or
\code{PATH_EXISTS_OR_INVALID}. A refusal is not a written export.
}
\seealso{\code{\link{ru_analyze_plan}},
\code{\link{ru_analyze_code}}, \code{\link{ru_analyze_execute}}}
\examples{
# No file is created by this deliberately refused example.
not_ready <- ru_analyze_plan(list())
ru_analyze_export(not_ready, path = "not-authorized.txt")$status
}