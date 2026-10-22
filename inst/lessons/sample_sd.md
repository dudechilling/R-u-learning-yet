---
id: sample_sd
type: walkthrough
domain: Descriptive statistics
aliases: calculate range variance and standard deviation;spread;range;sample sd;summary of variability
related: range;variance;variance_sd;mean;quartiles
visual:
alt:
caption:
sources: https://search.r-project.org/R/refmans/stats/html/cor.html
status: VERIFIED
---
# How do I summarize range, variance, and standard deviation together?

## Immediate answer

Use `diff(range(x))` for the observed total width, `var(x)` for sample variance in squared units, and `sd(x)` for standard deviation in the original unit.

## Use this in R

```r
data(mtcars)
x <- mtcars$mpg
diff(range(x, na.rm=TRUE))
var(x, na.rm=TRUE)
sd(x, na.rm=TRUE)
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `mtcars$mpg` | The measured numeric variable | Your numeric column |
| `na.rm=TRUE` | How missing entries are treated | Report any omitted values |

## What to check

- Use at least two usable values for sample variance and SD.
- Range depends strongly on the two observed extremes.
- Variance has squared units; SD has original units.

## Interpret your results

Report each value with the appropriate unit and say that all three describe variability in the recorded sample, not proven population variability.

## Learn more

If a question also requests quartiles and trimmed mean, combine this method with `quantile()` and `mean(x,trim=.1)` after checking their assumptions.
