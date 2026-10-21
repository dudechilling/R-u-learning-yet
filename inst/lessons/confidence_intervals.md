---
id: confidence_intervals
type: walkthrough
domain: Sampling and inference
aliases: 95 percent confidence interval;CI;interval interpretation;coverage
related: mean_confidence_interval;standard_error;sample_size
visual:
alt:
caption:
sources: https://search.r-project.org/R/refmans/stats/html/t.test.html
status: VERIFIED
---
# How do I interpret a confidence interval?

## Immediate answer

A 95% confidence procedure covers a fixed target parameter in about 95% of repeated studies under its assumptions. The resulting interval is not a 95% probability assigned to a fixed parameter.

## Exam answer pattern

Name the parameter, sampling assumptions, coverage method and interval endpoints; explain repeated-procedure coverage.

## Use this in R

```r
data(iris)
x <- iris$Sepal.Length
out <- t.test(x,conf.level=.95)
c(mean=unname(out$estimate),lower=out$conf.int[1],
  upper=out$conf.int[2])
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `iris$Sepal.Length` | Numeric recorded sample | Your usable independent values |
| `conf.level=.95` | Long-run confidence level | Prespecified desired coverage |

## What to check

- A mean confidence interval does not contain 95% of individual values.
- Dependence or biased selection can undermine nominal coverage.
- The built-in iris example demonstrates R syntax, not a documented probability sample from a larger population.

## Interpret your results

The interval expresses uncertainty about a population quantity, not the full range of observed data.

## Learn more

Higher chosen confidence usually increases interval width with the data unchanged.
