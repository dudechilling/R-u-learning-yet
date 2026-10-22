---
id: poisson_upper_tail
type: walkthrough
domain: Probability and random variables
aliases: Poisson upper tail;ppois;more than;at least;exceeds
related: binomial;probability_events;probability_complement
visual:
alt:
caption:
sources: https://search.r-project.org/R/refmans/stats/html/Poisson.html
status: VERIFIED
---
# How do I compare more than and at least k Poisson events?

## Immediate answer

For more than k Poisson events use stats::ppois(k,lambda,lower.tail=FALSE). For at least k events include k by changing the cutoff to k-1. The synthetic worked example is not an assignment-specific answer.

## What the question asks

Identify the random variable, support or event-rate model, and event boundary.

## Recognize the method

Use the named method only with its prerequisites. Never use the same cutoff for strict and inclusive tails; direct upper-tail ppois avoids subtracting close-to-one probabilities.

## Numbered solution steps

1. Identify the model and its units. 2. Verify inputs and assumptions. 3. Translate the exact event operation. 4. Run the native R code and interpret the probability.

## Original worked example

With a fictional Poisson model of seven alerts per day, more than four excludes four, while at least four includes four; their difference is dpois(4,7).

## Use this in R

```r
lambda <- 7; k <- 4L
stopifnot(is.finite(lambda), lambda >= 0, is.finite(k),
 k >= 0, k == floor(k))
c(more = stats::ppois(k, lambda, lower.tail = FALSE),
  at_least = stats::ppois(k - 1L, lambda, lower.tail = FALSE))
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| lambda | Expected alerts per day | Finite nonnegative mean per interval |
| k | Boundary count | Whole nonnegative integer |
| lower.tail | Direct upper tail | Keep FALSE |

## What to check

Check finite and valid model inputs; no private datasets or observed measurements are supplied. Where a probability vector is used, require nonnegative entries and total mass one.

## Interpret your results

For more than k use P(X>k), for at least k use P(X>=k)=P(X>k-1). For k=0 the at-least probability is one.

## Frequent mistakes

Never use the same cutoff for strict and inclusive tails; direct upper-tail ppois avoids subtracting close-to-one probabilities.

## Learn more

Official R documentation: https://search.r-project.org/R/refmans/stats/html/Poisson.html. Explanation and examples are original.
