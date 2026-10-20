\name{ru}
\alias{ru}
\alias{ru_find}
\alias{ru_plan}
\alias{ru_run}
\alias{ru_code}
\alias{ru_topics}
\alias{ru_inputs}
\alias{ru_hist}
\alias{ru_bar}
\alias{ru_box}
\alias{ru_scatter}
\title{Find and solve RStudio problems}
\description{Search practical questions, follow evidence-dependent steps, and run standalone examples. Plot helpers use base R.}
\usage{
ru(query, have = NULL, missing = NULL)
ru_find(query, n = 10L)
ru_plan(query, have = NULL, missing = NULL)
ru_run(query)
ru_code(query)
ru_topics()
ru_inputs()
ru_hist(x, units = "Value", title = "Distribution", breaks = "Sturges",
        col = "#CEE2F0", show_mean = TRUE, show_median = TRUE)
ru_bar(x, title = "Category counts", xlab = "Category",
       col = "#9DC6E2")
ru_box(x, groups = NULL, units = "Value", title = "Spread and outliers")
ru_scatter(x, y, xlab = "X", ylab = "Y",
           title = "Paired measurements", show_fit = TRUE,
           labels = NULL, col = "#3F78A8")
}
\arguments{
\item{query}{Plain-language question, keyword, or exact problem ID.}
\item{have}{Known available input labels.}
\item{missing}{Input labels confirmed absent. Unmentioned inputs stay unknown.}
\item{n}{Maximum number of matching problems to display.}
\item{x}{Numeric observations or categories appropriate to the plot type.}
\item{y}{A second numeric vector, aligned one-to-one with x.}
\item{units}{Units for the measured quantity.}
\item{title}{Graph title.}
\item{breaks}{Histogram break method or break positions.}
\item{col}{Bar or point color.}
\item{show_mean}{Whether to draw a mean reference line.}
\item{show_median}{Whether to draw a median reference line.}
\item{xlab}{Horizontal axis label.}
\item{groups}{Optional categorical group labels.}
\item{ylab}{Vertical axis label.}
\item{show_fit}{Whether to draw a straight-line regression fit.}
\item{labels}{Optional text labels aligned with original observations.}
}
\details{These scripts use invented data. Console searches do not use a network connection. Inspect assumptions before applying any example to a real dataset.}
\examples{
ru_find("histogram")
ru_plan("histogram",have=c("numeric","units"),missing="groups")
}
