---
id: proportion_interval
type: walkthrough
domain: Core inference
aliases: Wilson score interval;binomial proportion CI;prop.test correct FALSE;confidence proportion
related: confidence_intervals;binomial;sampling_design
visual:
alt:
caption:
sources: https://stat.ethz.ch/R-manual/R-devel/library/stats/html/prop.test.html
status: VERIFIED
---
# How do I calculate a two-sided Wilson interval for one proportion?

## Immediate answer

The Wilson score interval estimates one binomial success probability. It remains within zero and one and differs from the simple Wald interval. The native calculation below uses the normal critical value and the score-interval formula without continuity correction.

## What the question asks

How do I calculate a two-sided Wilson interval for one proportion? The worked data are constructed, not supplied by a learner.

## Recognize the method

Use a whole number of successes out of a positive whole number of independent trials with a common success probability. This is interval estimation, not a hypothesis test, difference between proportions, exact Clopper-Pearson interval or weighted-survey interval.

## Numbered solution steps

1. Define success, the trial unit and the target population.
2. Validate successes, total trials and the two-sided confidence level.
3. Use z = qnorm((1+confidence)/2) in the Wilson formula.
4. Report the estimate and both probability bounds with the sampling limitations.

## Original worked example

A fictional quality check records 17 successes in 50 independent trials. Estimate the success probability with a 95% Wilson interval. These counts are invented to demonstrate the calculation.

## Use this in R

```r
successes <- 17L
total <- 50L
confidence <- 0.95
if (!is.numeric(successes) || length(successes) != 1L ||
    !is.numeric(total) || length(total) != 1L ||
    !is.finite(successes) || !is.finite(total) || total < 1 ||
    successes < 0 || successes > total ||
    successes != floor(successes) || total != floor(total))
  stop("Supply integer successes between zero and a positive integer total.")
if (!is.numeric(confidence) || length(confidence) != 1L ||
    !is.finite(confidence) || confidence <= 0 || confidence >= 1)
  stop("Set confidence strictly between zero and one.")
p_hat <- successes / total
z <- stats::qnorm((1 + confidence)/2)
denominator <- 1 + z^2/total
center <- (p_hat + z^2/(2*total))/denominator
half_width <- z * sqrt(p_hat*(1-p_hat)/total + z^2/(4*total^2))/denominator
interval <- pmin(1, pmax(0, c(center-half_width, center+half_width)))
result <- c(estimate = p_hat, lower = interval[1L], upper = interval[2L])
result
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| successes | Binary successes | A nonnegative whole count no larger than total |
| total | Independent trial count | A positive whole count, not a sum of arbitrary weights |
| confidence | Two-sided interval level | A prespecified value strictly between zero and one |

## What to check

- A binomial model requires an adequately justified common probability and independence. Heterogeneity, clustering, finite-population sampling or response bias can require another analysis.

- Wilson is a score-based approximate interval, not an exact-coverage guarantee. Boundary counts are allowed; an observed zero is not proof that the true probability is zero.

## Interpret your results

The estimate is successes divided by trials. The two bounds describe an interval for a population probability, not an interval containing a fixed percentage of individual binary values. Coverage concerns repetitions of the stated sampling procedure.

## Frequent mistakes

Do not label this a Wald or Clopper-Pearson interval. Do not interpret the selected confidence level as a probability distribution for a fixed frequentist parameter.

## Learn more

Use the linked official R documentation for argument and return-value semantics. This explanation, constructed case and native R example were independently authored for this library; source links are not copied lessons.
