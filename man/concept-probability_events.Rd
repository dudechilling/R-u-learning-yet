\name{probability_events}
\alias{probability_events}
\alias{sample_space}
\alias{complement_event}
\alias{statistical_experiment}
\concept{sample space}
\concept{experiment}
\concept{event}
\concept{complement}
\concept{intersection}
\concept{union}
\title{Experiments, Sample Spaces and Probability Events}
\description{A probability experiment is a repeatable or clearly described chance process with possible outcomes. Its sample space lists all possible elementary outcomes under the stated model. An event is any collection of those outcomes.}
\section{Explanation}{
An \emph{outcome} is one possible result. The \emph{sample space}, often called S, is the full set of outcomes the experiment allows. An \emph{event}, such as "the result is greater than 4", is a subset of the sample space. The \emph{complement} of an event is every outcome in the same sample space \emph{not} in that event. Its probability is 1 minus the probability of the original event.

The \emph{intersection} of events A and B means both occur. Their \emph{union} means at least one occurs (including both). The sample space changes if a question adds a second draw, a second roll, replacement, or another condition. Define it before calculating.

When all elementary outcomes are equally likely, probability of an event equals the number of favorable outcomes divided by the total. If outcomes have unequal probabilities, counting alone is insufficient.
}
\section{Practical example}{
Suppose a fair six-sided die is rolled. S = \{1, 2, 3, 4, 5, 6\}. The event "larger than 4" is \{5, 6\}; its complement is \{1, 2, 3, 4\}. Under a \emph{fair die model}, their probabilities are 2/6 and 4/6, which add to one. These are model outcomes, not newly recorded observations.
}
\section{Important distinctions}{
The sample space is the collection of \emph{possible} outcomes, not the results observed in a small sample. A set of observed frequencies is not necessarily a set of model probabilities. The probability of "A or B" must not double-count their overlap; check \link{conditional_independence} for the relationship between intersecting, exclusive and independent events.
}
\section{Limitations}{
You cannot infer equal chances solely from the names of the outcomes. For draws without replacement, possible outcomes and conditional probabilities change after an item is removed. Some experiments have continuous outcomes, where individual outcomes may have probability zero and intervals carry positive probability.
}
\section{R application}{
Represent possible equally likely discrete outcomes with a vector. Use logical comparisons to select an event, then count how many are selected; this is a \emph{constructed probability model}. For observed category frequencies, \code{table()} and \code{prop.table()} are descriptive and require a suitable sampling basis for broader claims.
}
\seealso{\link{conditional_independence}, \link{probability_distributions}, \link{population_sample}, \link{r_table}}
\references{
\url{https://www.itl.nist.gov/div898/handbook/eda/section3/eda366.htm}
}
\examples{
S <- 1:6                   # modeled outcomes for a fair die
event <- S > 4             # outcomes 5 and 6
mean(event)                # 2 / 6, if all outcomes equally likely
mean(!event)               # 4 / 6, the complement
stopifnot(sum(event)+sum(!event)==length(S))
}