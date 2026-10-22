---
id: uniform_interval
type: walkthrough
domain: Probability and random variables
aliases: uniform interval;punif difference;between two bounds;inside continuous uniform range;uniform probability interval
related: uniform_cdf;normal_between;discrete_cdf
visual:
alt:
caption:
sources: https://search.r-project.org/R/refmans/stats/html/Uniform.html
status: VERIFIED
---
# How do I find the chance that a continuous uniform variable falls between two values?

## Immediate answer

For U ~ Uniform(a,b) with finite a < b and lower < upper, P(lower < U < upper) equals stats::punif(upper,min=a,max=b) minus stats::punif(lower,min=a,max=b). The CDF automatically clips intervals extending beyond the support. The following worked example is original and does not supply an answer to an assessment.

## What the question asks

Find the area of a continuous uniform distribution inside the specified outcome interval. This is a probability about U, not a confidence interval for an unknown parameter.

## Recognize the method

Use a continuous uniform model with two numeric endpoints and known support [a,b]. A single cutoff instead belongs to uniform_cdf. Reject binomial or Poisson counts, discrete PMFs/CDFs, normal models and interval estimation. Endpoints must be supplied in the same units as a and b.

## Numbered solution steps

1. Confirm continuous Uniform(a,b), with finite a < b and a common unit.
2. Express the event with two ordered numeric bounds lower < upper; bounds may extend outside [a,b].
3. Find the uniform CDF at the upper endpoint and subtract the CDF at the lower endpoint.
4. Verify the result lies between 0 and 1; alternatively divide the intersecting interval length by b-a.
5. Explain that strict and inclusive endpoint choices have the same probability for a continuous variable.

## Original worked example

Consider a fictional waiting interval U, uniform from 2 to 14 minutes. Find P(5 < U < 11): the overlap spans 6 of 12 minutes, giving 0.5. For an interval from -3 to 5 minutes, the overlap with [2,14] is 3 minutes, giving 0.25.

## Use this in R

```r
a_minutes <- 2
b_minutes <- 14
lower_minutes <- 5
upper_minutes <- 11
outside_lower_minutes <- -3
outside_upper_minutes <- 5
inputs <- c(a_minutes, b_minutes, lower_minutes, upper_minutes,
            outside_lower_minutes, outside_upper_minutes)
stopifnot(all(is.numeric(inputs)), all(is.finite(inputs)),
          a_minutes < b_minutes, lower_minutes < upper_minutes,
          outside_lower_minutes < outside_upper_minutes)
interval_area <- stats::punif(upper_minutes, min = a_minutes, max = b_minutes) -
  stats::punif(lower_minutes, min = a_minutes, max = b_minutes)
clipped_area <- stats::punif(outside_upper_minutes, min = a_minutes, max = b_minutes) -
  stats::punif(outside_lower_minutes, min = a_minutes, max = b_minutes)
c(inside = interval_area, partly_outside = clipped_area)
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `a_minutes` | Lower uniform support, minutes | Finite lower bound of assumed uniform outcome |
| `b_minutes` | Upper uniform support, minutes | Finite upper bound strictly greater than a |
| `lower_minutes` | Lower event limit, minutes | Finite number below upper_minutes |
| `upper_minutes` | Upper event limit, minutes | Finite number above lower_minutes |
| `outside_lower_minutes` | Illustrative second lower limit, minutes | Optional out-of-support example lower cutoff |
| `outside_upper_minutes` | Illustrative second upper limit, minutes | Optional out-of-support example upper cutoff |

## What to check

- All six illustrated numbers must be finite; support and each interval must be ordered. A bound outside [a,b] is allowed and clipped by punif; reversed limits are invalid for this guide.
- A continuous uniform model has no point masses: P(lower < U < upper) = P(lower <= U <= upper). The fraction of support length inside the interval is a separate arithmetic oracle.

## Interpret your results

Under the constructed model the inside interval has probability 0.5, while the partly-outside interval has probability 0.25. Neither value is a confidence level or an observed frequency. The two probabilities refer to separate example intervals.

## Frequent mistakes

Do not calculate dunif at one endpoint as an interval probability, and do not subtract a discrete count PMF. Do not assume a requested interval must lie inside the uniform support; overlap length, not raw interval length, controls its probability.

## Learn more

Official R documentation (API facts, not copied text): https://search.r-project.org/R/refmans/stats/html/Uniform.html. All examples, wording and synthetic data are independently authored.