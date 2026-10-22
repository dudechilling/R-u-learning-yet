---
id: discrete_cdf
type: walkthrough
domain: Probability and random variables
aliases: discrete CDF;cumulative table;F(x);probability above threshold
related: binomial;probability_events;probability_complement
visual:
alt:
caption:
sources: https://search.r-project.org/R/refmans/base/html/cumsum.html
status: VERIFIED
---
# How do I calculate the CDF from a discrete table?

## Immediate answer

The discrete CDF is F(k)=P(X<=k): add all masses whose support values are at or below the boundary. P(X>k) sums masses strictly above it. The synthetic worked example is not an assignment-specific answer.

## What the question asks

Identify the random variable, support or event-rate model, and event boundary.

## Recognize the method

Use the named method only with its prerequisites. Never confuse the CDF with expected value or assume unit-spaced support.

## Numbered solution steps

1. Identify the model and its units. 2. Verify inputs and assumptions. 3. Translate the exact event operation. 4. Run the native R code and interpret the probability.

## Original worked example

For fictional support 0.5, 1.5, 3, F(1.8) = 0.7 and P(X > 1.8) = 0.3.

## Use this in R

```r
x <- c(0.5, 1.5, 3)
p <- c(0.2, 0.5, 0.3)
stopifnot(length(x) == length(p), !anyNA(x), !anyNA(p),
  !anyDuplicated(x), all(is.finite(x)), all(is.finite(p)),
  all(p >= 0), abs(sum(p) - 1) < 1e-12)
o <- order(x); x <- x[o]; p <- p[o]
F <- cumsum(p); k <- 1.8
stopifnot(all(diff(F) >= 0), abs(tail(F, 1) - 1) < 1e-12)
c(at_most = sum(p[x <= k]), above = sum(p[x > k]))
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| x | Unique numeric support | Real outcomes including nonintegers |
| p | Probability mass at support | Nonnegative total 1 |
| k | Numeric threshold | Keep fractional cutoff |

## What to check

Check finite and valid model inputs; no private datasets or observed measurements are supplied. Where a probability vector is used, require nonnegative entries and total mass one.

## Interpret your results

The CDF F(k) includes equality at k. P(X>k) excludes equality. Sorting support makes cumsum monotone; its final value must be one.

## Frequent mistakes

Never confuse the CDF with expected value or assume unit-spaced support.

## Learn more

Official R documentation: https://search.r-project.org/R/refmans/base/html/cumsum.html. Explanation and examples are original.
