---
id: poisson_cdf
type: walkthrough
domain: Probability and random variables
aliases: Poisson CDF;ppois;cumulative Poisson;at most arrivals
related: binomial;probability_events;probability_complement
visual:
alt:
caption:
sources: https://search.r-project.org/R/refmans/stats/html/Poisson.html
status: VERIFIED
---
# How do I find at most k Poisson events?

## Immediate answer

For a Poisson count, use stats::ppois(k,lambda) to calculate P(X<=k), including the boundary k and every smaller nonnegative count. The synthetic worked example is not an assignment-specific answer.

## What the question asks

Identify the random variable, support or event-rate model, and event boundary.

## Recognize the method

Use the named method only with its prerequisites. ppois gives a cumulative probability; dpois gives the mass at one count. Do not route this to binomial.

## Numbered solution steps

1. Identify the model and its units. 2. Verify inputs and assumptions. 3. Translate the exact event operation. 4. Run the native R code and interpret the probability.

## Original worked example

For a fictional process averaging seven events per shift, the probability of at most four in a shift is about 0.1729916.

## Use this in R

```r
lambda <- 7; k <- 4L
stopifnot(is.finite(lambda), lambda >= 0, is.finite(k),
 k >= 0, k == floor(k))
stats::ppois(k, lambda)
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| lambda | Mean per selected interval | Nonnegative count rate |
| k | Inclusive upper bound | Whole nonnegative integer |

## What to check

Check finite and valid model inputs; no private datasets or observed measurements are supplied. Where a probability vector is used, require nonnegative entries and total mass one.

## Interpret your results

P(X<=4) includes outcomes zero through four. The rate and interval must agree.

## Frequent mistakes

ppois gives a cumulative probability; dpois gives the mass at one count. Do not route this to binomial.

## Learn more

Official R documentation: https://search.r-project.org/R/refmans/stats/html/Poisson.html. Explanation and examples are original.
