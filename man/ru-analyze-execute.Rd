\name{ru_analyze_execute}
\alias{ru_analyze_execute}
\title{Confirm and Execute a Current Numeric Description}
\description{
Run the supported descriptive computation only after a ready
analysis plan, explicit Run confirmation, and revalidation against
current bound data. A code preview and an eligible plan alone never
authorize execution.
}
\usage{
ru_analyze_execute(plan, data, confirm = FALSE)
}
\arguments{
\item{plan}{An unchanged, sealed \code{READY} plan from
\code{ru_analyze_plan()}.}
\item{data}{The current base \code{data.frame}, or
\code{list(data = current_frame, source_context = current_record)}
when the plan was bound to a declared source context. Using a bare
frame with a source-bound plan requires revalidation and is refused.}
\item{confirm}{One nonmissing logical. Omission defaults to
\code{FALSE}, which cancels an otherwise ready run. Only an explicit
\code{TRUE} requests execution; this is a low-level parameter, not
proof of a tested human-facing consent interface.}
}
\details{
The plan seal is checked before confirmation. An invalid plan or
malformed confirmation returns \code{FAILED}; an otherwise ready
run with \code{confirm = FALSE} returns \code{CANCELLED}, without
running the computation. With confirmation, the current data,
source-context metadata, declared exclusions and plan identity
are independently checked again. Changes to rows, values, columns,
source revision or attestation invalidate the old run and return
\code{REVALIDATION_REQUIRED} rather than silently reusing it.

On success, only the recorded numeric outcome is summarized:
raw/observed/missing counts, mean, median, sample standard deviation
(\code{NA} with fewer than two usable readings), extrema, and optionally
a histogram with its declared bin convention. The result is
descriptive, not a population or causal inference. Failure and
cancellation are not successful execution and cannot be exported as
verified results.
}
\value{
A \code{ru_analysis_result} list with \code{status} and
\code{reason}. Status is \code{SUCCEEDED}, \code{CANCELLED},
\code{FAILED}, or \code{REVALIDATION_REQUIRED}. A successful result
contains \code{plan_id}, current \code{binding}, a derived
\code{value} list, \code{measurement_unit}, \code{engine_version},
and \code{result_sha256}; it contains no raw research rows.
Other outcomes return a reason and possibly \code{plan_id}.
}
\seealso{\code{\link{ru_analyze}}, \code{\link{ru_analyze_plan}}, \code{\link{ru_analyze_code}},
\code{\link{ru_analyze_export}}}
\examples{
not_ready <- ru_analyze_plan(list())
ru_analyze_execute(not_ready, data.frame(reading = 1:3))$status
\dontrun{
# Using an unchanged READY plan with its CURRENT data:
cancelled <- ru_analyze_execute(plan, current_data, confirm = FALSE)
result <- ru_analyze_execute(plan, current_data, confirm = TRUE)
# Pass a current source-context bundle instead for a source-bound plan.
}
}