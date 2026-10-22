\name{statistical_variable}
\alias{statistical_variable}
\alias{statistical_variables}
\concept{statistical variable}
\concept{variable in statistics}
\concept{observational unit}
\title{What is a statistical variable?}
\description{A statistical variable is a characteristic recorded or measured for each unit in a study. The value can differ between units, such as a car's fuel economy or its weight. A data-frame column often stores the recorded values of one variable.}
\section{Immediate answer}{
A \emph{variable} describes what is measured or classified. An \emph{observation} is a recorded case, such as one vehicle. For 398 vehicles, \code{mpg} and \code{weight} can be two statistical variables with 398 recorded values each.

A statistical variable is not the same as an R object. The R command \code{mpg <- df$mpg} creates an R object named \code{mpg} that holds an existing variable's observed values; it does not itself create new observations.
}
\section{Examples}{
Fuel economy measured in miles per gallon is numeric. Vehicle class is categorical. A numerical code can still represent categories, so inspect the meaning of values before choosing averages, histograms, or bar charts.
}
\section{Important distinctions}{
A \emph{unit} is the thing studied; a \emph{variable} describes a property of units; a \emph{value} is the recorded property for one unit. An R \emph{object} is a container in the software, while a data-frame \emph{column} commonly stores the values of a variable.
}
\section{Limitations}{
A data frame may contain derived variables, missing records, repeated observations, or summary rows rather than independent study units. Column names alone cannot establish a study's measurement quality, representativeness or sampling design.
}
\section{R application}{
Use \code{names(df)} and \code{str(df)} to inspect recorded column names and types. To select a column and assign its values to an R object use \code{mpg <- df$mpg} as explained in \link{r_objects_columns}. Choose subsequent methods according to the variable's meaning: \code{table()} for categories and \code{hist()} for suitable numeric measurements.
}
\seealso{\link{r_objects_columns}, \link{measurement_scales}, \link{population_sample}}
\references{
\url{https://www.itl.nist.gov/div898/handbook/eda/section3/eda34.htm}
}
\examples{
data(mtcars)
names(mtcars)
str(mtcars[c("mpg","wt")])
}