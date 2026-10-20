\name{ru_guide}
\alias{ru_guide}
\alias{ru_edit}
\title{Read a worked guide and make an editable R script}
\description{Read the canonical worked problem guide from an installed package, or copy its standalone example script into your project. No browser, online access, or second documentation collection is required.}
\usage{
ru_guide(query)
ru_edit(query, dir = getwd(), open = interactive())
}
\arguments{
\item{query}{Problem ID or unambiguous question found with \code{ru_find()}.}
\item{dir}{Existing directory for the editable R script. Defaults to the current working directory.}
\item{open}{Whether to open the copied script in the editor. Defaults to interactive sessions.}
}
\details{\code{ru_guide()} prints the existing Quarto source in the Console. \code{ru_edit()} makes a new named \code{.R} script in the working directory and refuses to replace an existing file. Review the source and change the dataset, variable names, units, or test assumptions before running against your own data.}
\examples{
ru_guide("histogram")
scratch <- tempfile(pattern="rulearn-demo-")
dir.create(scratch)
path <- ru_edit("histogram", dir=scratch, open=FALSE)
stopifnot(file.exists(path))
unlink(scratch, recursive=TRUE)
}