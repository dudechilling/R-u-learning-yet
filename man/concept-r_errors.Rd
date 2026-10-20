\name{r_errors}
\alias{r_errors}
\alias{object_not_found}
\alias{numeric_imported_as_text}
\concept{R errors}
\concept{object not found}
\concept{error recovery}
\title{Recognize and Recover from Common R Errors}
\description{When an R command fails, read the error, inspect the data and object names, then correct the cause. Do not try random calculations or delete observations until you understand the problem.}
\section{Quick answer}{Use \code{names()}, \code{str()}, \code{class()}, \code{is.na()} and the relevant native \code{?function} help page to identify what the command expected and what R actually received. Check spelling, capitalization and row alignment first.}
\section{Object not found}{
An error such as \code{object 'height' not found} usually means that R cannot find an object with the exact name you supplied. R distinguishes \code{Height} from \code{height}. A data-frame column needs a reference such as \code{measurements$height}, or a suitable \code{data=} argument in a formula-based function.

Use \code{names(measurements)} to see actual columns, \code{ls()} for available objects, and \code{str(measurements)} for types. Do not invent a column based on what you expected to be in the data.
}
\section{Numeric data imported as text}{
A \code{non-numeric argument} or \code{argument is not numeric or logical} message can mean that measurements were imported as character strings. Check \code{str(data)} and \code{unique(data$column)}. Commas, units, missing-value markers, and inconsistent decimal separators may need to be resolved at import.

Do not use \code{as.numeric()} blindly on a factor: it can return internal category codes instead of the printed measurements. Do not silently replace unparseable values with zero.
}
\section{Missing values}{
The result \code{NA} is an absence or undefined value, not the number zero. Use \code{is.na()} to count missing observations, then inspect where and why they occurred. \code{na.rm=TRUE} changes which observations are summarized. With paired columns, keep the two values from each original row together.
}
\section{Function not found}{
An error such as \code{could not find function} may mean a misspelled function or a package that is not installed or loaded. Try \code{help.search("function name")}, check the actual package documentation, and use \code{package::function} when you know the package. R's built-in \code{mean()}, \code{sd()} and \code{hist()} already have their own help pages.
}
\section{Learning from the error}{
Identify the first incorrect assumption: the dataset is loaded, a column exists, a value is numeric, an observation has a partner, or a model assumption is justified. Change one justified item and rerun that line. This is more reusable than memorizing a single error-specific workaround.
}
\section{Limitations}{
A command running without an error does not prove that the chosen statistical method is suitable, that the sample is representative, or that a result is causal. When unsure about the design, stop before interpreting inference.
}
\seealso{\link{population_sample}, \link{mean_median}, \link{variance_sd}, \code{\link[utils]{str}}, \code{\link[base]{names}}, \code{\link[base]{is.na}}}
\references{
\url{https://docs.posit.co/ide/user/ide/guide/ui/ui-panes.html}

\url{https://search.r-project.org/R/refmans/utils/html/help.search.html}
}
\examples{
data(iris)
names(iris)
str(iris)
is.numeric(iris$Sepal.Length)
sum(is.na(iris$Sepal.Length))
# Names are case-sensitive. Check what the table actually contains.
}