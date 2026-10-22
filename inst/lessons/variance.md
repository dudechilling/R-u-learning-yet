---
id: variance
type: walkthrough
domain: Descriptive statistics
aliases: sample variance;var;x variance;spread squared units;n minus one
related: variance_sd;mean;range;interquartile_range
visual:
alt:
caption:
sources: https://search.r-project.org/R/refmans/stats/html/cor.html
status: VERIFIED
---
# How do I calculate sample variance in R?

## Immediate answer

Use `var(x)` for sample variance. It summarizes squared deviations from the sample mean using an `n - 1` denominator when observations are available.

## Use this in R

```r
data(mtcars)
x <- mtcars$mpg
var(x)
length(x)
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `mtcars$mpg` | Numeric measurements | Your numeric column |
| `var(x)` | Sample variance | Keep R’s standard sample convention |

## What to check

- Use at least two usable numeric observations.
- Variance has squared measurement units: squared miles-per-gallon in this example.
- Missing entries require explicit handling; do not treat them as zeros.

## Interpret your results

A larger variance indicates greater spread in squared units among these recorded values. It does not prove a population property.

## Learn more

`sd(x)` gives the square root of the sample variance in the original unit. This makes standard deviation more immediately interpretable.
