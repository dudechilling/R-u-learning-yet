---
id: uniform_cdf
type: walkthrough
domain: Probability and random variables
aliases: uniform CDF;punif;continuous uniform;at or below;F(x);uniform probability
related: uniform_interval;probability_events;discrete_cdf
visual:
alt:
caption:
sources: https://search.r-project.org/R/refmans/stats/html/Uniform.html
status: VERIFIED
---
# How do I find a cumulative probability for a continuous uniform variable?

## Immediate answer

For U uniformly distributed between finite bounds a and b (a < b), F(x) = P(U <= x) is stats::punif(x, min = a, max = b). Its value is 0 below a, (x-a)/(b-a) inside the support, and 1 at or above b. The probability at any single point is zero; for P(U > x) use 1 - F(x). The following worked example is original and does not supply an answer to an assessment.

## What the question asks

The question seeks the fraction of the uniform probability area to the left of an observed threshold, rather than a density, a quantile or a random draw. The model parameters and threshold must use the same units.

## Recognize the method

Select a continuous Uniform(a,b) model only when the equal-density assumption on [a,b] is justified. Use punif for cumulative probabilities, dunif for density, qunif for inverse-quantile questions, and runif for simulation. Do not use punif to compute correlations, normal tails or discrete counts.

## Numbered solution steps

1. Identify the continuous outcome U and confirm that Uniform(a,b) is the assumed model.
2. Specify finite a and b in the outcome's units and require a < b.
3. Pick the numerical threshold x; do not mistake it for a desired probability.
4. Evaluate punif(x, min=a, max=b); for a continuous variable, < and <= agree at a point.
5. Interpret the answer as model-based cumulative area, not a measurement from actual records.

## Original worked example

Imagine a hypothetical machine whose idle time U is uniformly distributed from 1 to 9 seconds. Find the chance its idle time is at most 4 seconds. By geometry, the fraction is (4-1)/(9-1) = 3/8 = 0.375. Check a threshold below the range, one inside it, its upper endpoint and a point above that endpoint.

## Use this in R

```r
a_seconds <- 1
b_seconds <- 9
x_seconds <- 4
stopifnot(is.numeric(a_seconds), length(a_seconds) == 1L,
          is.numeric(b_seconds), length(b_seconds) == 1L,
          is.numeric(x_seconds), length(x_seconds) == 1L,
          all(is.finite(c(a_seconds, b_seconds, x_seconds))),
          a_seconds < b_seconds)
cdf_at_x <- stats::punif(x_seconds, min = a_seconds, max = b_seconds)
boundary_x <- c(a_seconds - 1, a_seconds + 2,
                b_seconds, b_seconds + 1)
boundary_cdf <- stats::punif(boundary_x, min = a_seconds, max = b_seconds)
c(at_most_4 = cdf_at_x, below_support = boundary_cdf[1L],
  inside_support = boundary_cdf[2L],
  at_upper_end = boundary_cdf[3L],
  above_support = boundary_cdf[4L])
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `a_seconds` | Lower support bound, seconds | Finite real minimum in the outcome's units |
| `b_seconds` | Upper support bound, seconds | Finite real maximum strictly greater than a |
| `x_seconds` | Cumulative threshold, seconds | Finite real cutoff for F(x) |
| `boundary_x` offsets | Illustrative endpoint checks | Optional demonstration values relative to a and b |

## What to check

- The assumed outcome is continuous with constant density 1/(b-a) within [a,b]. Bounds are finite and ordered; x is finite. An empirical histogram does not establish a uniform probability model.
- The right cumulative limit equals 1, the left limit is 0, and the CDF is nondecreasing. A single exact outcome has probability zero, even at the endpoints.

## Interpret your results

In the invented model, P(U <= 4 seconds) = 0.375. The example's four boundary checks are 0, 0.25, 1 and 1; therefore P(U > 10 seconds) = 0. Since U is continuous, the probability of exactly 4 seconds is 0, not 0.375.

## Frequent mistakes

Do not confuse punif (CDF) with dunif (density), qunif (quantile) or runif (sampling). Do not use a continuous CDF for a discrete PMF, and do not turn a point threshold into a two-bound interval without a second limit.

## Learn more

Official R documentation (API facts, not copied text): https://search.r-project.org/R/refmans/stats/html/Uniform.html. All examples, wording and synthetic data are independently authored.