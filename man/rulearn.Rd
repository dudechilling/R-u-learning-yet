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
\title{Search and Read RStudio References}
\description{Search locally across statistical concepts, R functions, and practical walkthroughs, and retrieve native R help articles or editable scripts. Existing plotting and method helpers remain available.}
\usage{
ru(query, have = NULL, missing = NULL)
ru_find(query, n = 10L, type = NULL)
ru_plan(query, have = NULL, missing = NULL)
ru_run(query)
ru_code(query)
ru_topics()
ru_inputs()
ru_hist(x, units = "Value", title = "Distribution", breaks = "Sturges",
        col = "#CEE2F0", show_mean = TRUE, show_median = TRUE)
ru_bar(x, title = "Category counts", xlab = "Category",
       col = "#9DC6E2")
ru_box(x, groups = NULL, units = "Value", title = "Spread and outliers", col = NULL)
ru_scatter(x, y, xlab = "X", ylab = "Y",
           title = "Paired measurements", show_fit = TRUE,
           labels = NULL, col = "#3F78A8")
}
\arguments{
\item{query}{Plain-language question, search keyword, or exact reference or walkthrough ID.}
\item{have}{Known available input labels.}
\item{missing}{Input labels confirmed absent. Unmentioned inputs stay unknown.}
\item{n}{Maximum matching entries returned invisibly; the Viewer normally
shows the single clear top result or an ambiguous-results page.}
\item{type}{Optional content filter: \code{"concept"}, \code{"function"}, or \code{"walkthrough"}.}
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
\details{
In RStudio, \code{ru_find()} opens a compact local HTML lesson in the
existing Viewer when a reviewed reference is available. If several topics
may apply, it shows a short list with meaningful distinctions; if none
match, it shows an explicit no-match page. No network access or Quarto
runtime is required to read the installed short reference.

Successful lookup calls return structured results invisibly without
printing long lists to the Console. \code{ru_topics()} opens the scoped
coverage catalogue with honest content status labels. The installed
catalogue includes unfinished topics; inspect its current rows and status
fields with \code{ru_topics()}.

Native R \code{help()} remains available. \code{ru_text()} explicitly
prints a short reference summary for an ordinary terminal without the
RStudio Viewer. Existing calculation and plotting helpers remain
available for compatibility, but are not required for learning.
Examples use named recorded R datasets or explicitly constructed models.
Executing a command does not validate measurement or study assumptions.
}
\examples{
ru_find("What is stationarity?")
ru_find("How do I make a histogram?")
ru_plan("histogram",have=c("numeric","units"),missing="groups")
}
