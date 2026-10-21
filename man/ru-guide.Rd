\name{ru_guide}
\alias{ru_guide}
\alias{ru_edit}
\title{Read a worked guide and make an editable R script}
\description{Read the canonical worked problem guide from an installed package, or copy its standalone example script into your project. No browser, online access, or second documentation collection is required.}
\usage{
ru_guide(query)
ru_edit(query, dir = getwd(), open = interactive(),
        mode = c("full", "quick", "both"))
}
\arguments{
\item{query}{Problem ID or unambiguous question found with \code{ru_find()}.}
\item{dir}{Existing directory for the editable R script. Defaults to the current working directory.}
\item{open}{Whether to open the copied script in the editor. Defaults to interactive sessions.}
\item{mode}{For revised guides, select the detailed example (\code{"full"}, default), the short independent example (\code{"quick"}), or both sections (\code{"both"}). Older guides may have only a full example.}
}
\details{\code{ru_guide()} displays a formatted Rd version of the
installed canonical Quarto walkthrough. In RStudio, \code{previewRd()}
uses the existing Help pane; outside RStudio, the guide is printed as
readable plain text. Raw Quarto fences and execution directives are not
displayed as lesson content. Older guides that use \code{ru_apply()} are
marked as compatibility examples, not native R commands.

\code{ru_edit()} copies an ordinary editable \code{.R} file into a
user-selected directory without overwriting an existing file. In
RStudio, it uses the Source editor when the RStudio API is available.
The default \code{mode="full"} preserves the annotated walkthrough.
\code{mode="quick"} selects a shorter runnable example when available;
\code{mode="both"} copies the entire canonical script. Check data
types, units and assumptions before applying code to new records.}
\examples{
ru_guide("histogram")
scratch <- tempfile(pattern="rulearn-demo-")
dir.create(scratch)
path <- ru_edit("histogram", dir=scratch, open=FALSE)
stopifnot(file.exists(path))
unlink(scratch, recursive=TRUE)
}