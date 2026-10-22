\name{function_stem}
\alias{r_stem}
\alias{function_stem}
\concept{R function stem}
\concept{stem-and-leaf display}
\concept{stem and leaf plot}
\title{stem() - Print a Stem-and-Leaf Display}
\description{Use \code{stem()} to display the distribution of numeric observations as printed digits. Each leaf represents an observation, so the display preserves more of the recorded numerical detail than a histogram bar.}
\section{Immediate answer}{Try \code{stem(iris$Sepal.Width)} after \code{data(iris)}. This prints a stem-and-leaf display in the Console; it is not a saved graphics object.}
\section{Syntax}{\preformatted{stem(x, scale = 1, width = 80, atom = 1e-08)}}
\section{Important arguments}{
\code{x} supplies the numeric values to examine. \code{scale} changes the displayed stem length and grouping: a higher value generally makes the plot longer. \code{width} controls the target character width. Consult R's native \code{?stem} for exact behavior.
}
\section{Reading the result}{
Read R's line telling you where the decimal point is before interpreting the digits. A stem and leaf together reconstruct a displayed value at the shown precision. Read the axis \emph{units} from the source variable, not from the printed digits alone. More repeated leaves in a row indicate more observations in that range.
}
\section{Adapting the example}{
Replace \code{iris$Sepal.Width} with another numerical column and identify its units. Use \code{str(your_data)} and \code{is.numeric(your_data$your_column)} first. Try \code{scale=2} if the default display groups too many measurements on a single stem.
}
\section{Mistakes and limitations}{
Do not use \code{stem()} on species names or ordered categories; consider \code{table()} or \code{barplot()} instead. The display can become unwieldy with thousands of values; then a histogram may be easier to read. Printed rounding and the scale convention matter; a display is not a causal or inferential test.
}
\seealso{\link{r_hist}, \link{measurement_scales}, \link{descriptive_inferential}, \code{\link[graphics]{stem}}}
\references{\url{https://search.r-project.org/R/refmans/graphics/html/stem.html}}
\examples{
data(iris)
stem(iris$Sepal.Width)
stem(iris$Sepal.Width, scale=2)
# The recorded units are centimetres.
}