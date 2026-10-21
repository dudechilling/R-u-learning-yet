\name{r_objects_columns}
\alias{r_objects_columns}
\alias{r_assignment}
\alias{r_columns}
\concept{R objects}
\concept{create variables in R}
\concept{assignment operator}
\concept{data frame columns}
\title{Create R objects and select data-frame columns}
\description{To store values in R, use \code{<-} to assign a value to a named object. Use \code{$} to select a named column from a data frame. An R object name is not the same thing as the statistical variable it stores.}
\section{Immediate answer}{
Suppose your imported CSV is already in a data frame named \code{df} and contains columns named \code{mpg} and \code{weight}:
\preformatted{
mpg <- df$mpg
weight <- df$weight
}
\code{df} is the data frame. \code{df$mpg} selects the \code{mpg} column from it. \code{<-} assigns those values to an object named \code{mpg}. The second line repeats this operation for \code{weight}. You can then use \code{mean(mpg)} or \code{hist(mpg)} after checking that the data are suitable.
}
\section{What to change}{
Replace \code{df} with the data-frame name you used when importing your file. Replace the column names on the right with the exact names from \code{names(df)}. The object names on the left can be anything sensible that does not conflict with an existing object.

For example, in the built-in \code{mtcars} data, fuel economy is called \code{mpg} and the weight column is called \code{wt}, not \code{weight}. Therefore, \code{mtcars$weight} is not a valid replacement.
}
\section{What to check}{
First run \code{is.data.frame(df)} and \code{names(df)}. Confirm that the expected columns exist with \code{all(c("mpg", "weight") \%in\% names(df))}. If a name is missing, check spelling and capitalization before doing any calculations. Using \code{$} with a nonexistent column can return \code{NULL}, so do not assume a missing-name selection succeeded.

The assignment operator creates an R object; it does not create a new CSV column. The new object is separate from the data-frame column. Be careful about changing either later.
}
\section{Create a new data-frame column}{
To add or replace a column inside the data frame, put \code{df$} on the \emph{left}:
\preformatted{
df$mpg_per_weight <- df$mpg / df$weight
}
This example calculates a derived ratio from two existing numerical columns. Its usefulness and units depend on what \code{weight} measures and whether zero, negative or missing values need special handling. Do not create this ratio merely because the code runs.

To assign a whole new value without using a data-frame column:
\preformatted{
speed_limit <- 50
}
}
\section{More explanation}{
R stores values in named objects. Some objects hold a single value, others a vector of values, or a table called a data frame. A data-frame column usually has one element for each row. The \code{$} operator extracts one column by name.

With a CSV of 398 rows, assigning \code{mpg <- df$mpg} gives \code{mpg} one entry per recorded row (provided the column exists), not an average. For an actual average use \code{mean(mpg, na.rm=TRUE)} only after checking numerical type and missing values. See R's official \code{?assignOps} and \code{?Extract}.
}
\section{Practice (optional)}{
Use \code{data(mtcars)}. Without copying the worked answer, put the \code{mpg} and \code{wt} columns into new objects. Check their lengths. Then add a correctly named derived column to a \emph{copy} of the data frame and explain how it differs from the original. Do not overwrite your imported lab data when experimenting.
}
\seealso{\link{statistical_variable}, \link{r_errors}, \link{r_sd},
 \code{\link[base]{assignOps}}, \code{\link[base]{Extract}}, \code{\link[base]{data.frame}}}
\references{
\url{https://search.r-project.org/R/refmans/base/html/assignOps.html}

\url{https://search.r-project.org/R/refmans/base/html/Extract.html}
}
\examples{
df <- mtcars                 # built-in recorded vehicle data
mpg <- df$mpg                # store one column in an object
weight <- df$wt              # column name is wt here, not weight
stopifnot(length(mpg)==nrow(df),length(weight)==nrow(df))
stopifnot(all(c("mpg","wt") \%in\% names(df)))
df$mpg_per_wt <- df$mpg / df$wt  # derived values in new column
}