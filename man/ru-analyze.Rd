\name{ru_analyze}
\alias{ru_analyze}
\title{Prepare a Local Question-First Numeric Analysis App}
\description{
Construct the W2 RU Analyzing Shiny application for the single supported
\code{describe.numeric} method. Creating the application does not start
Shiny, choose a study design on the user's behalf, or execute a calculation.
}
\usage{
ru_analyze(data = NULL, spec = NULL)
}
\arguments{
\item{data}{Optional locally supplied ordinary base \code{data.frame},
or a named list \code{list(data = current_frame,
source_context = current_record)}. Omission constructs an app with
no attached data and an explicit need to select data before planning.
Invalid data and unsupported types are refused by the planner rather
than being silently repaired.}
\item{spec}{Optional closed \code{1.1-draft.v2} method specification for
the supported numeric descriptive workflow. With \code{NULL}, the
consumer starts from a descriptive \code{summary.only} template but
still requires the user to select a question, data and outcome. An
incompatible method produces a typed refusal during plan review,
not an alternative test selected by inference.}
}
\details{
With local \pkg{shiny}, \pkg{bslib}, and \pkg{digest} available,
the function constructs a \code{shiny.appobj}; it does not call
\code{shiny::runApp()}. The caller must deliberately launch the
application. Missing dependencies yield a structured
\code{UNAVAILABLE} response instead of automatic installation.

The question-first interface asks the learner to select the question,
locally provided data, numeric column and missingness policy. It
separately records any explicit consent to exclude missing outcomes.
The learner reviews a typed analysis plan before requesting inspectable
ordinary R code, then must affirm a separate Run checkbox and action
before execution. Changes to the selected question, column, policy or
histogram options invalidate the previous plan and result.
A preview remains \code{NOT_EXECUTED}; the calculation runs only
through \code{ru_analyze_execute()} with current-data revalidation.

The histogram consumer requires explicit breakpoints and exposes
interval closure, including a left-closed option; the original
right-closed iris instructional figure is a separate example and must
not be relabeled. An export panel requests a local destination and
fresh affirmative authorization and delegates to the restricted
\code{ru_analyze_export()} pathway; raw rows remain unsupported.
The private authorization helper is not a public stand-alone
human-consent API. Existing files and invalid/stale destinations
are refused.

Only descriptive numeric sample summaries are implemented. The
interface does not establish population inference, verified student
competence, portability outside the supported identity domain, or
actual Windows/RStudio Viewer, browser keyboard, screen-reader,
human-consent, or rights clearance. Automated Shiny server testing is
different from those human and platform qualifications.
}
\value{
Normally a \code{shiny.appobj} for a local, explicitly launched
question-first consumer, with no analysis executed when it is
constructed. If dependencies are missing, a list with
\code{status = "UNAVAILABLE"},
\code{reason = "ANALYZE_DEPENDENCIES_MISSING"},
\code{missing_dependencies} and an explanatory \code{detail}.
Plan, preview, execution and export statuses belong to the
corresponding separate functions and reactive UI actions; they
are not returned as completed calculations by \code{ru_analyze()}.
}
\seealso{\code{\link{ru_analyze_plan}},
\code{\link{ru_analyze_code}}, \code{\link{ru_analyze_execute}},
\code{\link{ru_analyze_export}}, \code{\link{ru_reference}}}
\examples{
# Construct only. No Shiny server is started and no analysis runs.
if (requireNamespace("shiny", quietly = TRUE) &&
    requireNamespace("bslib", quietly = TRUE) &&
    requireNamespace("digest", quietly = TRUE)) {
  app <- ru_analyze()
  inherits(app, "shiny.appobj")
}
\dontrun{
# Explicit local launch, never automatic:
current_data <- data.frame(reading = c(13, 18, 20))
app <- ru_analyze(data = current_data)
shiny::runApp(app)
}
}