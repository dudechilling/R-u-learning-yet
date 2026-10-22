---
id: mean_confidence_interval
type: walkthrough
domain: Sampling and inference
aliases: mean confidence interval unknown sigma;t interval for one mean;sample sd mean CI;estimated population standard deviation;Student t confidence interval;one sample mean interval
related: ci_method_selection;mean_ci_z;standard_error;confidence_intervals
visual:
alt:
caption:
sources: https://search.r-project.org/R/refmans/stats/html/t.test.html
status: VERIFIED
---
# How do I calculate a two-sided confidence interval for one mean when population SD is unknown?

## Immediate answer

When the population standard deviation sigma is unknown and is estimated by the sample SD s, the usual two-sided one-sample t confidence interval is sample_mean +/- qt(1 - alpha/2, df=n-1) * s/sqrt(n), where alpha = 1 - confidence_level. In native R, stats::t.test(x, conf.level=confidence_level) computes this interval for a single numeric sample. The sample design and small-sample assumptions must justify its use.

## What the question asks

Estimate the fixed population mean of one numeric variable from one appropriately sampled population, using the uncertainty in the estimated SD. This is interval estimation, not a hypothesis test and not a two-group comparison.

## Recognize the method

Choose this reference if a mean interval is required and population sigma is unavailable or explicitly estimated using sample s. Use mean_ci_z only when population sigma is independently known (not when someone calculated s from the same sample). A binary yes/no parameter is a proportion; a matched pair or two independent groups requires a separate design-specific method.

## Numbered solution steps

1. Verify the numerical sample contains n >= 2 finite, nonmissing observations from the intended one-population design; check that the sampling units are adequately independent.
2. Calculate sample mean and sample SD s in the same measured units; require s > 0 for this t.test example. Set confidence_level strictly between 0 and 1.
3. Use standard error s/sqrt(n), degrees of freedom n - 1 and the two-sided critical value qt(1 - alpha/2, df=n-1).
4. Compute mean +/- critical_value * standard_error, or use stats::t.test(x, conf.level=confidence_level)$conf.int.
5. Report both endpoints with units and explain coverage under the sampling/model assumptions. Small n is particularly sensitive to nonnormality and influential observations.

## Original worked example

Seven imaginary independently sampled workshop devices produced vibration readings of 4.2, 4.8, 5.1, 4.5, 5.3, 4.9 and 5.0 millimetres per second. Population SD is not known, so estimate it from these seven values and use a two-sided 95% t interval for the hypothetical population mean. This dataset is constructed for teaching, not evidence of random sampling in a real workshop.

## Use this in R

```r
measurements <- data.frame(vibration_mm_s = c(4.2, 4.8, 5.1, 4.5, 5.3, 4.9, 5.0))
column <- "vibration_mm_s"
confidence_level <- 0.95
stopifnot(is.data.frame(measurements), column %in% names(measurements),
          is.numeric(confidence_level), length(confidence_level) == 1L,
          is.finite(confidence_level), confidence_level > 0,
          confidence_level < 1)
x <- measurements[[column]]
stopifnot(is.numeric(x), !is.complex(x), length(x) >= 2L,
          all(is.finite(x)), stats::sd(x) > 0)
n <- length(x)
sample_sd <- stats::sd(x)   # Estimated s, NOT a known population sigma
fit <- stats::t.test(x, conf.level = confidence_level)
interval <- unname(fit$conf.int)
stopifnot(length(interval) == 2L, all(is.finite(interval)))
c(n = n, sample_mean = mean(x), sample_sd = sample_sd,
  df = n - 1L, lower = interval[1L], upper = interval[2L])
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `measurements` | One synthetic dataset | Your appropriately collected data frame |
| `column` | Numeric measurements in millimetres per second | The exact numeric column to estimate |
| `sample_sd` | Estimated s from the data, not known sigma | Leave stats::sd(x); do not substitute a population-SD claim |
| `n` | Number of usable independent sample units; t df = n - 1 | Leave length(x), then verify each row's sampling unit |
| `confidence_level` | Two-sided confidence level | Prespecified number strictly between 0 and 1 (e.g., 0.90, 0.95, 0.99) |
| Units / missingness | Measurement scale and completeness | Report your units; resolve NA, Inf or excluded units explicitly, never silently omit them |

## What to check

- An iid random sample from a normal population gives exact classical t coverage; for other populations, justification for approximate t coverage depends on sample size, shape, independence and sampling design. The CLT is not a universal n >= 30 certificate.
- Small samples with strong skew or outliers may require a different analysis. A mean CI does not become representative merely because stats::t.test returned a number.
- This example rejects n < 2, missing/nonfinite values, constant observations and invalid confidence levels rather than printing plausible limits. Confirm why observations would be independent before interpreting the interval.

## Interpret your results

A 95% procedure aims to cover the fixed population mean in 95% of repetitions of the stipulated sampling design and model. It does not mean 95% of individual vibration readings fall inside the interval, or that a fixed unknown mean has a 95% probability of lying in the observed numerical endpoints.

## Frequent mistakes

Do not use qnorm with an estimated sample SD as if sigma were known; do not use t.test to claim a known-sigma z interval. Do not use this one-sample example for a paired difference or two independent groups without selecting and checking the appropriate design-specific method.

## Learn more

The existing full mean_confidence_interval Quarto guide and ru_edit example remain available for legacy navigation and ru_apply compatibility. The compact code above uses ordinary stats::t.test directly; the linked official R documentation describes its defaults, confidence interval and handling of missing or nonfinite values.