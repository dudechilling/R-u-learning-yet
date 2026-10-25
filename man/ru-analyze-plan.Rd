\name{ru_analyze_plan}
\alias{ru_analyze_plan}
\title{Check Eligibility for One Numeric Description}
\description{
Validate an explicit analysis specification against the current typed
data frame and optional declared source context. Return a nonexecuting
plan or a typed refusal. W2 implements only
\code{method_id = "describe.numeric"}, not general model selection.
}
\usage{
ru_analyze_plan(spec, data = NULL, source_context = NULL)
}
\arguments{
\item{spec}{A named base list with exactly the G1
\code{1.1-draft.v2} specification fields. Supply
\code{method_id = "describe.numeric"}, a supported operation
(\code{"summary.only"} or \code{"summary.histogram"}), the numeric
\code{outcome}, explicit descriptive objective/design and
missingness policy, operation-specific \code{parameters}, and
\code{user_attestations}. Invalid or absent decisions are not
filled in automatically.}
\item{data}{Current ordinary base \code{data.frame}; \code{NULL} is
not sufficient for a ready plan. The portable identity codec
currently admits automatically numbered rows, unique ASCII column
names, and unclassed logical, integer, double, and ASCII character
columns without other attributes. Unsupported data are rejected.}
\item{source_context}{Optional \code{ru.source_context.v1} record for
the current source and parsed data. Its declared roles, version,
sampling-unit and physical measurement-unit metadata must match
the current frame. A local \code{serialize()} fingerprint alone is
not a portable planner identity.}
}
\details{
The specification is closed: unknown or repeated fields, invalid
arguments, mismatched source metadata, unsupported types, and
unsupported method families do not produce a ready plan.
For \code{"summary.histogram"}, explicit breakpoints, count/density
scale, \code{include_lowest}, and interval closure are required;
unequal-width count bins are not silently accepted.

The function counts missing numeric outcomes. With a missing outcome
value, \code{missingness_policy = "report"} requires a treatment
decision, \code{"fail"} rejects the plan, and
\code{"complete_case_with_consent"} requires recorded affirmative
user attestation. It never imputes zero, infers independence, or
asserts why observations are missing.

\code{READY} means eligible for this descriptive computation
subject to the recorded design, not executed, statistically
inferentially valid, or certified by a human. A ready plan carries
an engine/codec identity and binding to the checked data, without
embedding raw research rows. The qualified canonical codec is
intentionally restricted; unsupported identities fail closed.
Execution and result export independently require current-data
revalidation and other gates.
}
\value{
A \code{ru_analysis_plan} list with \code{status} and \code{reason}.
Status is \code{READY}, \code{NEEDS_INPUT}, \code{INVALID}, or
\code{UNSUPPORTED}. A ready response additionally includes
\code{plan_id}, \code{seal}, \code{engine_version}, the validated
\code{spec}, \code{binding}, \code{source_metadata}, declared
\code{measurement_unit} and \code{unit_evidence}, plus
\code{checked} sample/missingness counts and \code{exclusion}
policy information. Other statuses explain what prevents eligibility.
The plan is not an analysis result.
}
\seealso{\code{\link{ru_analyze}}, \code{\link{ru_analyze_code}},
\code{\link{ru_analyze_execute}}, \code{\link{ru_source_context}}}
\examples{
# A constructed, entirely observed numeric teaching frame.
spec <- list(
  schema_version = "1.1-draft.v2", method_id = "describe.numeric",
  operation = "summary.only", parameters = list(report_nonfinite = TRUE),
  objective = "describe", estimand = "empirical_sample_distribution",
  outcome = "reading", predictors = NULL, grouping = NULL,
  unit_id = NULL, dependence = "unknown", design = "descriptive",
  sampling = "not_applicable", missingness_policy = "report",
  inference_target = "sample_only", confidence_level = NULL,
  user_attestations = list()
)
teaching <- data.frame(reading = c(13, 18, 20))
plan <- ru_analyze_plan(spec, teaching)
plan$status
# These are example values, not an independently verified study.
with_missing <- data.frame(reading = c(13, NA_real_, 18, 20))
ru_analyze_plan(spec, with_missing)$reason
}