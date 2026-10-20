\name{conditional_independence}
\alias{conditional_independence}
\alias{independent_events}
\alias{mutually_exclusive}
\alias{conditional_probability_concept}
\concept{event independence}
\concept{independent events}
\concept{mutually exclusive events}
\concept{conditional probability}
\concept{probability given}
\title{Independent, Mutually Exclusive and Conditional Events}
\description{Conditional probability asks: what is the chance of event A \emph{given that} event B occurred? Independent events do not change one another's probabilities. Mutually exclusive events cannot occur together. These are different ideas.}
\section{Explanation}{
If event B has positive probability, the conditional probability of A given B is the probability that \emph{both} occur, divided by the probability of B: \eqn{P(A|B)=P(A \cap B)/P(B)}.

Events A and B are \emph{independent} if observing one leaves the probability of the other unchanged: \eqn{P(A|B)=P(A)} when B has positive probability. Equivalently, \eqn{P(A \cap B)=P(A)P(B)}.

Events are \emph{mutually exclusive} if they cannot both occur; their overlap has probability zero. Two events with positive probabilities cannot be both mutually exclusive and independent: learning that one happened rules out the other.

For sampling without replacement, a first draw can change the chances on a second draw. Describe the sequence and the remaining items before multiplying conditional probabilities.
}
\section{Practical example}{
On a single fair six-sided die roll let A mean "even" and B mean "above 3". Event A has probability 3/6. Event B has probability 3/6. Both happen on 4 or 6, so the probability of A given B is (2/6)/(3/6) = 2/3, not 1/2. These events are not independent, although they can occur together.

By contrast, "even" and "odd" on the same roll are mutually exclusive; knowing it was even makes the probability of odd zero. The calculation is a fair-die model, not a record of observed rolls.
}
\section{Important distinctions}{
\emph{Independent events} are a probability concept. \emph{Independent samples} and \emph{paired observations} describe how data are collected; see \link{independent_paired}. \emph{Conditional} does not mean the events must overlap: if the intersection is empty and B has positive probability, the conditional probability of A given B is zero.
}
\section{Limitations}{
The formula needs \eqn{P(B)>0}. In real observational studies, independence is an assumption to justify from the process or sampling design, not something that can be safely inferred from names. A product of event probabilities is valid for an intersection of independent events, but for dependent draws use the correct sequence of conditional probabilities.
}
\section{R application}{
With an equally likely, enumerated sample space, calculate \code{mean(A & B)/mean(B)} after verifying \code{mean(B)>0}. For recorded data, \code{table()} and \code{prop.table()} summarize frequencies; they do not establish a probabilistic sampling design on their own. A probability based on equally likely cards or dice is a constructed model.
}
\seealso{\link{probability_events}, \link{probability_distributions}, \link{independent_paired}, \link{r_table}}
\references{
\url{https://www.itl.nist.gov/div898/handbook/eda/section3/eda366.htm}
}
\examples{
die <- 1:6
A <- die %% 2 == 0      # even
B <- die > 3            # above 3
pA <- mean(A)
pAgivenB <- mean(A & B)/mean(B)
c(pA=pA, pAgivenB=pAgivenB)  # 0.5 versus 2/3
stopifnot(mean(B)>0)
}