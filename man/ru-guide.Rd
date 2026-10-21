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
\details{
\code{ru_guide()} opens the chosen installed walkthrough as compact local
HTML in RStudio's existing Viewer. Where a reviewed compact lesson exists,
it presents the immediate answer, copyable ordinary R code, an editable
elements table, validity checks, interpretation and optional detail.
Older long-form guides remain available but show a clear compatibility
notice instead of raw Quarto source or hidden execution instructions.

\code{ru_edit()} copies an ordinary editable \code{.R} file to the given
folder, refuses to overwrite it and opens it in RStudio's Source editor
when available. If a new compact lesson has no older script, it copies
exactly its displayed native R code. For existing revised walkthroughs,
\code{mode="quick"} selects the short example and \code{mode="full"}
selects the detailed standalone script. Outside RStudio, these calls
return paths or search results invisibly; request \code{ru_text()} for a
short explicit Console explanation.
}
\examples{
ru_guide("histogram")
scratch <- tempfile(pattern="rulearn-demo-")
dir.create(scratch)
path <- ru_edit("histogram", dir=scratch, open=FALSE)
stopifnot(file.exists(path))
unlink(scratch, recursive=TRUE)
}