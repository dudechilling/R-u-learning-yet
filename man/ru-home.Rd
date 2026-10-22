\name{ru_home}
\alias{ru_home}
\title{Open the Offline Learning Home}
\usage{ru_home(open = TRUE)}
\arguments{\item{open}{One logical value. If \code{TRUE}, display the home in a supported interactive RStudio session. If \code{FALSE}, prepare local files without opening a window.}}
\description{Prepare the local Field Atlas home, learning paths, references and help. No network connection or remote service is used.}
\details{In supported interactive RStudio sessions, package attachment opens this home once per attach event. Set \code{options(rulearn.auto_home = FALSE)} before \code{library(rulearn)} to disable automatic opening. The package does not change persistent preferences. Noninteractive sessions, child jobs and unsupported IDEs do not automatically open a Viewer or external browser. Explicit calls outside RStudio give a concise text fallback. An attach-time home error does not prevent use of the package.}
\value{The local HTML path, invisibly. Files are created under the current R session temporary directory.}
\seealso{\code{\link{ru_find}}, \code{\link{ru_text}}, \code{\link{ru_topics}}}
\examples{home <- ru_home(open = FALSE)
file.exists(home)
}
