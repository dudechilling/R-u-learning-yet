\name{ru_capabilities}
\alias{ru_capabilities}
\title{Inspect Observed RU Runtime Capabilities}
\description{
Report the detected R environment, selected optional package availability,
and current RU route availability without launching an interface.
}
\usage{
ru_capabilities()
}
\details{
The function checks namespace availability and installed versions for
\pkg{shiny}, \pkg{bslib}, \pkg{learnr}, \pkg{filelock}, \pkg{digest},
and \pkg{rstudioapi}. If \pkg{rstudioapi} is present, it probes
\code{rstudioapi::isAvailable()}, treating probe errors as
\code{FALSE}. It does not run a graphical or accessibility test.

The selector and reference catalogue are reported \code{SUPPORTED}.
The Learn and Analyze consumers are reported \code{UNAVAILABLE} with
reason \code{NOT_IMPLEMENTED}. The reference Viewer is reported
\code{UNTESTED} when RStudio is detected, otherwise
\code{UNAVAILABLE}. Progress writing is reported \code{UNTESTED}
when \pkg{filelock} is installed and \code{UNAVAILABLE} otherwise.
Detection of a package, IDE, or route is not a guarantee of Windows
compatibility, installed help opening, statistical correctness,
permission to write, or release qualification.
}
\value{
An object of class \code{ru_capabilities} containing
\code{schema_version}, \code{R} (R version string),
\code{platform}, \code{rstudio_detected} (one logical),
\code{packages} (a data frame with \code{package}, \code{installed},
and \code{version}), and \code{routes} (a data frame with
\code{mode}, \code{status}, and \code{reason}). The listed routes are
\code{selector}, \code{learn}, \code{analyze},
\code{reference_catalogue}, \code{reference_viewer}, and
\code{progress_write}. Route labels describe observed or expressly
unimplemented W1 behavior, not full functional acceptance.
}
\seealso{\code{\link{ru_workspace}}, \code{\link{ru_reference}},
\code{\link{ru_progress}}}
\examples{
cap <- ru_capabilities()
cap$packages
cap$routes
}
