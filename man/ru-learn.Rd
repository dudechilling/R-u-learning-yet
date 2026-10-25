\name{ru_learn}
\alias{ru_learn}
\title{Select an Installed Foundation Lesson}
\description{
Return a structured route for one of the first three installed RU Learning
lessons. A selection or a launch request does not demonstrate learning,
successful RStudio Source execution, or independent competence.
}
\usage{
ru_learn(path = NULL, lesson = NULL, resume = TRUE)
}
\arguments{
\item{path}{\code{NULL} or exactly \code{"foundation"}. This selects
the only installed W2 learning path; it is not a filesystem path.}
\item{lesson}{\code{NULL} for the foundation lesson selector, or one
exact ID: \code{"ru.learning.foundation.01"},
\code{"ru.learning.foundation.02"}, or
\code{"ru.learning.foundation.03"}.}
\item{resume}{One nonmissing logical value indicating whether resumption
was requested. It is not evidence that saved lesson state was found,
recovered, or independently verified.}
}
\details{
With \code{lesson = NULL}, the function returns the catalogue without
launching a tutorial, even when \code{path} was omitted. With a valid
lesson ID it checks the installed \pkg{rulearn} tutorial file and
returns \code{READY_TO_LAUNCH} or \code{UNAVAILABLE}. In a noninteractive
R session no launch is attempted and \code{opened} remains
\code{FALSE}. In an interactive session, an installed lesson is passed to
\code{learnr::run_tutorial()} when \pkg{learnr} is available. A returned
\code{opened = TRUE} means launch was requested, not that a student
completed the tutorial or passed a keyboard, screen-reader, or Windows
Viewer check.

The three lessons use \pkg{learnr} guided practice. Exercise results,
H0--H3 hints, and \code{resume_requested} do not establish independently
performed Source/Console transfer or a verified achievement record.
Invalid arguments raise a condition of class \code{ru_invalid_argument}.
}
\value{
A \code{ru_learning_route} list. Selection returns
\code{status = "SELECTOR"}, the foundation \code{path},
the \code{lessons} table (ID, tutorial name, title),
\code{opened = FALSE}, \code{resume_requested},
\code{resume_verified = FALSE}, and \code{progress_claim = "NONE"}.
An exact lesson returns the requested \code{lesson_id}, installed
\code{tutorial} name, \code{status} (\code{READY_TO_LAUNCH} or
\code{UNAVAILABLE}), possible \code{reason_code}, \code{opened},
\code{capability_status}, and the same noncertifying resume/progress
fields. No return field represents demonstrated student competence.
}
\seealso{\code{\link{ru_workspace}}, \code{\link{ru_progress}},
\code{\link{ru_reference}}}
\examples{
choices <- ru_learn()
choices$status
choices$lessons$id
lesson <- ru_learn(lesson = "ru.learning.foundation.03", resume = FALSE)
lesson$status
lesson$opened
}