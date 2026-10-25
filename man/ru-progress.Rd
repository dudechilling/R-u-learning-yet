\name{ru_progress}
\alias{ru_progress}
\title{Read Validated Local RU Progress Metadata}
\description{
Read the latest available versioned local progress record and return
its validated metadata. This function does not grade work or prove
student competence.
}
\usage{
ru_progress()
}
\details{
Progress generations, when present, are stored as local RDS metadata
under the \pkg{rulearn} user data directory returned by
\code{tools::R_user_dir("rulearn", "data")}. With no saved generations,
the function returns an empty table at revision zero. It validates
the latest generation's envelope, schema, revision, column types,
and consistency of evidence labels. A corrupt or unknown latest
generation raises \code{ru_state_corrupt} or
\code{ru_state_unknown_schema}; the function does not silently
roll back or repair it.

Allowed metadata statuses are \code{introduced} with
\code{exposure}, \code{practised} with \code{guided_attempt}, and
\code{performed_independently} with \code{independent_transfer}.
These are recorded claims tied to content versions and attempts,
not independently observed attainment. Reading does not modify
local progress. No remote gradebook or synchronized student
record is provided by this interface.
}
\value{
A data frame with exactly six columns:
\code{competency_id} (character), \code{content_version} (character),
\code{status} (character), \code{evidence_kind} (character),
\code{last_attempt} (character), and \code{review_recommended}
(logical). Attributes \code{storage_schema_version} and
\code{revision} identify the validated storage generation.
A fresh state has no rows, schema \code{"ru.progress.v1"}, and
revision \code{0L}.
}
\seealso{\code{\link{ru_workspace}}, \code{\link{ru_capabilities}}}
\examples{
progress <- ru_progress()
names(progress)
attr(progress, "revision")
}
