---
id: standard_error
type: walkthrough
domain: Sampling and inference
aliases: standard error;SE;sample standard deviation versus standard error;sd over sqrt n
related: sampling_distribution;central_limit_theorem;variance_sd
visual:
alt:
caption:
sources:
status: VERIFIED
---
# What is standard error and how is it different from SD?

## Immediate answer

Standard deviation measures the spread of individual observations. Standard error measures the sampling variability of a statistic; for independent identically distributed observations, estimated SE of a mean is sample SD divided by sqrt(n).

## Exam answer pattern

State which statistic is being estimated and whether the sampling assumptions justify its standard-error formula.

## Use this in R

```r
data(iris)
x <- iris$Sepal.Length
n <- length(x)
c(n=n,sample_sd=sd(x),estimated_se=sd(x)/sqrt(n))
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `iris$Sepal.Length` | Numeric measurements | Your sample variable |
| `n` | Number of independent usable measurements | Check missingness and dependence |

## What to check

- SE is not the same as a sample's SD.
- Clustered or repeated measurements often require another SE method.

## Interpret your results

A smaller SE reflects a more precise estimated mean under the model, not a less variable collection of individual observations.

## Learn more

For equal SD, quadrupling independent sample size approximately halves the standard error.
