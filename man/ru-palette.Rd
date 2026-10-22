\name{ru_palette}
\alias{ru_palette}
\title{Read Field Atlas Colors}
\description{Return the nine named Field Atlas colors from one local CSS
token source. This helper does not change plots, global R options or
RStudio settings.}
\usage{
ru_palette(role = NULL)
}
\arguments{
\item{role}{Optional one or more names: ocean, clay, jade, ochre, iris,
slate, warm-paper, deep-ink, or grid. Omit to return all nine.}
}
\details{The installed field-atlas.css file is the sole token definition
for HTML and R examples. Continuous data use suitable ordered color scales,
not the category palette. See base R help for copying native plot code.}
\examples{
ru_palette()
ru_palette("ocean")
}
