\name{ru_data}
\alias{ru_data}
\alias{ru_datasets}
\alias{ru_columns}
\title{Load and inspect openly accessible example datasets}
\description{Loads named datasets already distributed with R, or the optional publicly available penguins dataset. Reports column names, types and missing counts without modifying data.}
\usage{
ru_datasets()
ru_data(name)
ru_columns(data)
}
\arguments{
\item{name}{A case-sensitive dataset name displayed by \code{ru_datasets()}.}
\item{data}{A data frame.}
}
\details{Built-in examples require no download. For penguins, first install the optional palmerpenguins package explicitly using \code{install.packages("palmerpenguins")}. Penguins measurements were collected under the Palmer Station Long Term Ecological Research Program and distributed under CC0. The package does not silently substitute a different dataset when penguins are unavailable.}
\examples{
ru_datasets()
d <- ru_data("iris")
ru_columns(d)
}
