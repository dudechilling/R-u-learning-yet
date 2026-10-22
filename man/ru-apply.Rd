\name{ru_apply}
\alias{ru_apply}
\title{Legacy Convenience Interface for Applying Indexed Methods}
\description{The optional indexed calculation interface is retained for compatibility with earlier usage. To learn R, prefer the native R commands in \code{ru_guide()}, \code{ru_edit()}, and the concept/function references. Existing operations validate explicit inputs and cannot confirm study-design assumptions.}
\usage{
ru_apply(problem, data = NULL, x = NULL, y = NULL, group = NULL,
         time = NULL, threshold = NULL, prob = NULL, n = NULL, k = NULL,
         mu = NULL, sigma = NULL, confidence = NULL, reference = NULL,
         event = NULL, given = NULL, window = 3L, seed = 42L,
         reps = 500L, independent = FALSE, paired = FALSE,
         assume_normal = FALSE, alternative = "two.sided",
         new_x = NULL, allow_extrapolate = FALSE, weight = NULL,
         operator = ">=", file = NULL, successes = NULL, show_plot = TRUE,
         units = NULL, xlab = NULL, ylab = NULL, title = NULL, col = NULL)
}
\arguments{
\item{problem}{Exact problem ID, or an unambiguous question found by \code{ru_find()}.}
\item{data}{Your data frame. Not modified by the function.}
\item{x, y, group, time}{Column names in \code{data}, or aligned vectors.}
\item{threshold}{The selected value for filtering, a percentile target, interpolation target or normal tail cutoff.}
\item{prob}{Explicit probability (0 to 1).}
\item{n, k}{Number of trials or samples and a target success count.}
\item{mu, sigma}{Mean and positive standard deviation of an assumed normal model.}
\item{confidence}{Confidence level such as 0.95, specified explicitly for confidence procedures.}
\item{reference}{Null hypothesis reference mean.}
\item{event, given}{Values defining event A and event B.}
\item{window}{Moving-average width in observations.}
\item{seed}{Reproducible random seed.}
\item{reps}{Number of bootstrap replicates.}
\item{independent}{Set TRUE only after verifying that two groups are independent.}
\item{paired}{Set TRUE only after matching measurements by subject.}
\item{assume_normal}{Set TRUE only when a normal model is an acceptable assumption.}
\item{alternative}{Hypothesis test alternative.}
\item{new_x}{Predictor value for regression prediction.}
\item{allow_extrapolate}{Permit predictions outside the observed predictor range. Default is FALSE.}
\item{weight}{Optional column of nonnegative integer contingency-table counts.}
\item{operator}{One of \code{>=}, \code{>}, \code{<=}, \code{<}, \code{==}, or \code{!=} for row filtering.}
\item{file}{Existing CSV path for the import problem.}
\item{successes}{Success count for a proportion confidence interval.}
\item{show_plot}{Whether graph-producing methods should render plots. FALSE returns computed values without creating a graph.}
\item{units}{Measurement units or label for a histogram or boxplot.}
\item{xlab, ylab}{Explicit axis labels for supported plots; include units.}
\item{title}{Meaningful plot title for supported graph methods.}
\item{col}{Base R color for relevant plotted measurements.}
}
\details{Different problem IDs require different inputs; inspect \code{ru_plan(id)} and the worked example before calling. The function refuses arguments that the selected method does not use. These functions do not prove sampling assumptions, causal effects, or normality. A model-based calculation may be possible even when its interpretation is not justified.}
\examples{
d <- ru_data("iris")
ru_apply("mean_median", d, x="Sepal.Length")
ru_apply("group_means", d, x="Sepal.Length", group="Species")
}
