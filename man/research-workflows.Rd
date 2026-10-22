\name{research-workflows}
\alias{research-workflows}
\alias{glm_binomial}
\alias{bootstrap_mean}
\alias{multiple_testing_holm}
\title{Bounded Offline Research Workflows}
\description{Navigate three independently checked research examples: grouped binomial logistic regression, an iid mean bootstrap with percentile intervals, and Holm adjustment of a prespecified p-value family.}
\details{
The authoritative worked text and editable code live in the installed compact
lessons. Use \code{ru_open("glm_binomial")}, \code{ru_open("bootstrap_mean")},
or \code{ru_open("multiple_testing_holm")} in supported RStudio.
Use \code{ru_text("bootstrap_mean")} for an explicit terminal summary and code.
Use \code{ru_edit("bootstrap_mean", open=FALSE)} to prepare an editable script.

The binomial workflow uses one numeric predictor and a logit link with grouped
success/failure counts. Its bounded example requires both outcomes in every
group. It does not implement mixed, quasibinomial, probit or multinomial models.
Its odds-ratio interval is an approximate Wald interval.

The bootstrap workflow resamples iid numeric units with replacement. It
preserves the caller's RNG kind and state. A percentile interval is not a
coverage guarantee and cannot fix biased sampling or dependent observations.
Cluster, block, BCa and studentized variants are not substituted.

Holm adjustment requires valid raw p-values and the full prespecified family.
Familywise error control is not false-discovery-rate control. Multiplicity
adjustment does not validate the underlying study or estimate an effect size.

All example data are constructed. The recorded software and mathematical
checks do not imply actual Windows RStudio, legal or public-release acceptance.
}
\seealso{\code{\link{ru_home}}, \code{\link{ru_open}},
\code{\link[stats]{glm}}, \code{\link[stats]{p.adjust}}}
\examples{
ru_find("glm_binomial", n=1L)
ru_find("bootstrap_mean", n=1L)
ru_find("multiple_testing_holm", n=1L)
}