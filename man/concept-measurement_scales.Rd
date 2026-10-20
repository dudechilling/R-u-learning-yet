\name{measurement_scales}
\alias{measurement_scales}
\alias{scale_of_measurement}
\concept{scale of measurement}
\concept{nominal}
\concept{ordinal}
\concept{interval scale}
\concept{ratio scale}
\title{Measurement Scales: Labels, Order and Numerical Units}
\description{A measurement scale describes what comparisons a variable supports. Some variables give category names, some give an order, and some record numerical quantities with meaningful units. The right analysis depends on what the values mean, not how they look in R.}
\section{Explanation}{
\emph{Nominal categories} name types without an inherent ranking, such as flower species. \emph{Ordinal categories} have a meaningful order, such as small, medium and large, but the distance between adjacent labels is not necessarily equal. \emph{Interval scales} have meaningful numerical differences but an arbitrary zero, such as temperature in degrees Celsius. \emph{Ratio scales} additionally have a meaningful zero, such as length in centimetres.

An integer code (1, 2, 3) can still identify nominal groups rather than measured amounts. \code{mean()} on such labels can be mathematically computable yet meaningless. The most detailed source is not always the most suitable or ethical form to analyze: use the research question, privacy requirements and measurement quality to decide.
}
\section{Practical example}{
A date of birth can be converted to an age at a \emph{specified reference date}. Age in months may retain more detail than rounded age in years, but neither is universally the better measurement; context and privacy matter. Clothing-size categories carry order but do not measure equal gaps. Body measurements in centimetres can support numeric summaries, when measured consistently.

The built-in \code{iris} data include \code{Species}, a category, and \code{Sepal.Width}, a numeric length in centimetres.
}
\section{Important distinctions}{
Order is not equal spacing. A calendar date can support differences in days after conversion but the origin of calendar time is conventional. A ratio such as "twice as long" is meaningful for lengths, not for a raw calendar date. Variable storage types (numeric, character, factor, Date) are different from the scientific measurement scale.
}
\section{Limitations}{
A more precise value can still be biased or measured poorly. Converting an ordinal category into integers does not create a valid metric. Automated R checks cannot decide whether a recorded variable is ethically appropriate or adequately measured.
}
\section{R application}{
Use \code{str()} and \code{class()} to inspect storage types. Use \code{table()} and \code{barplot()} for nominal and ordinal categories. Use \code{hist()}, \code{mean()}, \code{median()} and \code{boxplot()} for numerical measurements where appropriate. Explain units on graph axes.
}
\seealso{\link{descriptive_inferential}, \link{mean_median}, \link{population_sample}, \link{r_table}, \link{r_hist}}
\references{
\url{https://www.itl.nist.gov/div898/handbook/eda/section3/eda34.htm}

\url{https://search.r-project.org/R/refmans/base/html/factor.html}
}
\examples{
data(iris)
str(iris[c("Species","Sepal.Width")])
table(iris$Species)                    # categorical counts
median(iris$Sepal.Width)              # centimetres
hist(iris$Sepal.Width, xlab="Sepal width (cm)")
}