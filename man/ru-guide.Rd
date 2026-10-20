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
\details{\code{ru_guide()} prints the installed reference with the quick and detailed native code extracted from the same source as the Quarto page. \code{ru_edit()} copies the selected example into a new named \code{.R} script, without requiring the student to change two separate examples. It refuses to overwrite an existing file. The default mode preserves the detailed walkthrough. Use \code{mode="quick"} for the immediate native example and \code{mode="both"} to copy the entire canonical script. Review dataset variables, units and assumptions before running against other observations.}
\examples{
ru_guide("histogram")
scratch <- tempfile(pattern="rulearn-demo-")
dir.create(scratch)
path <- ru_edit("histogram", dir=scratch, open=FALSE)
stopifnot(file.exists(path))
unlink(scratch, recursive=TRUE)
}