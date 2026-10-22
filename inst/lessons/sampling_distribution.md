---
id: sampling_distribution
type: walkthrough
domain: Sampling and inference
aliases: sampling distribution;distribution of sample means;repeated sampling
related: standard_error;central_limit_theorem;population_sample
visual:
alt:
caption:
sources:
status: VERIFIED
---
# What is a sampling distribution?

## Immediate answer

A sampling distribution describes the values a statistic would take across repeated samples selected under the same design. It is different from the distribution of individual measurements in one sample.

## Exam answer pattern

Name the statistic, sampling mechanism and population assumptions. Explain why different samples yield different values.

## Use this in R

```r
set.seed(7)            # Reproducible constructed model
means <- replicate(500,mean(rnorm(30,mean=10,sd=4)))
c(mean_of_means=mean(means),sd_of_means=sd(means))
hist(means,main="Constructed repeated sample means",
     xlab="Sample mean",col="#28627A")
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `rnorm(30,...)` | One constructed sample of 30 | Chosen sample size and model |
| `replicate(500,...)` | Number of repeated model samples | Enough to see the simulated shape |
| `set.seed(7)` | Reproducibility | Any recorded integer seed |

## What to check

- One observed dataset does not literally provide many independent repetitions.
- Sampling distributions reflect design and sample size, not just individual spread.

## Interpret your results

The sample mean may vary between samples even when the population mean is fixed.

## Learn more

Simulation can illustrate repeated sampling, but matching a model requires checking how units are sampled.
