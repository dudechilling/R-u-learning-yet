---
id: percentile_rank
type: walkthrough
domain: Descriptive statistics
aliases: percentile rank;38th percentile;how many scored above;position in sample;percentile versus quantile
related: quartiles;percentiles;cumulative_frequency
visual:
alt:
caption:
sources: https://search.r-project.org/R/refmans/stats/html/quantile.html
status: VERIFIED
---
# How do I interpret a percentile rank?

## Immediate answer

The 38th percentile is a cutoff at which roughly 38% of observations are at or below the value under a specified definition. It does not mean a score of 38 out of 100 or that 38% scored higher.

## Exam answer pattern

State the direction of the ranking, total number of observations and whether ties and the percentile definition are known. Estimate a count above the cutoff only with those qualifications.

## Use this in R

```r
data(iris)
x <- iris$Sepal.Length
cutoff <- unname(quantile(x,.38))
cutoff
mean(x <= cutoff)
sum(x > cutoff)
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `iris$Sepal.Length` | Recorded ranked measurements | Your numeric sample |
| `.38` | Target cumulative fraction | Requested percentile divided by 100 |
| `x <= cutoff` | Tie convention | Clarify below versus at-or-below |

## What to check

- For 101 participants, 62% is about 63 people, not an exact rank without a percentile convention and ties.
- Percentile rank of a measured value differs from the value at a requested percentile.

## Interpret your results

A percentile describes position in an ordered distribution, not the amount by which observations differ.

## Learn more

`quantile(x,probs=.38)` estimates a value at the 38th percentile; `mean(x<=v)` measures an observed share at/below v. These are related but not interchangeable when ties occur.
