---
id: five_number
type: walkthrough
domain: Descriptive statistics
aliases: five number;five-number;minimum q1 median q3 maximum;boxplot statistics
related: quartiles;interquartile_range;boxplot;outliers
visual:
alt:
caption:
sources: https://search.r-project.org/R/refmans/stats/html/fivenum.html
status: VERIFIED
---
# How do I obtain and interpret a five-number summary?

## Immediate answer

The five-number summary gives the recorded minimum, lower hinge or quartile, median, upper hinge or quartile, and maximum. It summarizes location and spread without describing the number of peaks.

## Exam answer pattern

Name all five ordered components and state which convention generated the quartiles. Contrast it with the whisker ends of a default boxplot.

## Use this in R

```r
data(iris)
fivenum(iris$Petal.Length)
quantile(iris$Petal.Length,c(0,.25,.5,.75,1))
boxplot.stats(iris$Petal.Length)$stats
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `iris$Petal.Length` | Numeric values | Your recorded column |
| `fivenum()` | Tukey five-number hinges | Use only if compatible with the course convention |
| `quantile()` | Five numerical cutoffs | Compare with required quartile rule |

## What to check

- `fivenum()` uses Tukey hinges, while `quantile()` defaults to another interpolation rule.
- Whiskers may stop short of the smallest/largest observations when points are flagged as outliers.

## Interpret your results

The five values describe the observed data range and middle portion. An unusual maximum remains a legitimate observation until separately checked.

## Learn more

Do not silently substitute axis limits for data extrema. A histogram can reveal modality missed by this summary.
