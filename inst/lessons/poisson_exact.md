---
id: poisson_exact
type: walkthrough
domain: Probability and random variables
aliases: Poisson exact;dpois;exactly arrivals;Poisson count
related: binomial;probability_events;probability_complement
visual:
alt:
caption:
sources: https://search.r-project.org/R/refmans/stats/html/Poisson.html
status: VERIFIED
---
# How do I find exactly k Poisson events?

## Immediate answer

For a Poisson count with mean lambda in the selected interval, use stats::dpois(k,lambda) to calculate P(X=k), the chance of exactly k events. The synthetic worked example is not an assignment-specific answer.

## What the question asks

Identify the random variable, support or event-rate model, and event boundary.

## Recognize the method

Use the named method only with its prerequisites. A fixed number of independent binary trials instead suggests binomial; do not use a daily rate with an hourly count.

## Numbered solution steps

1. Identify the model and its units. 2. Verify inputs and assumptions. 3. Translate the exact event operation. 4. Run the native R code and interpret the probability.

## Original worked example

In a hypothetical sensor model with mean 2.5 triggers per hour, the probability of exactly three in one hour is approximately 0.2137630.

## Use this in R

```r
lambda <- 2.5; k <- 3L
stopifnot(is.finite(lambda), lambda >= 0, is.finite(k),
 k >= 0, k == floor(k))
stats::dpois(k, lambda)
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| lambda | Expected events in interval | Nonnegative rate scaled to target interval |
| k | Requested exact count | Whole nonnegative integer |

## What to check

Check finite and valid model inputs; no private datasets or observed measurements are supplied. Where a probability vector is used, require nonnegative entries and total mass one.

## Interpret your results

dpois calculates P(X=k), a single mass rather than a cumulative probability. The mathematical value is exp(-2.5)*2.5^3/6.

## Frequent mistakes

A fixed number of independent binary trials instead suggests binomial; do not use a daily rate with an hourly count.

## Learn more

Official R documentation: https://search.r-project.org/R/refmans/stats/html/Poisson.html. Explanation and examples are original.
