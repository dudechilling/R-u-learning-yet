---
id: variance_sd
type: walkthrough
domain: Descriptive statistics
aliases: standard deviation;sd;spread;variability;calculate sd;standard deviation versus variance
related: variance;mean;standard_error;range
visual:
alt:
caption:
sources: https://search.r-project.org/R/refmans/stats/html/sd.html
status: VERIFIED
---
# How do I calculate sample standard deviation?

## Immediate answer

Use `sd(x)` for the sample standard deviation. It describes spread around the mean in the same units as the recorded measurement.

## Use this in R

```r
data(mtcars)
sd(mtcars$mpg)
var(mtcars$mpg)
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `mtcars$mpg` | Numeric measurement vector | Your numeric column |
| `sd()` | Sample standard deviation | Do not confuse with standard error |

## What to check

- Check missing values and use `na.rm=TRUE` only when appropriate.
- SD is not the mean absolute distance from the average.
- A large SD is relative to the measurement context, not automatically a problem.

## Interpret your results

Report the SD in miles per gallon alongside the sample mean when useful. It describes variability of the observed vehicles, not uncertainty in a population mean.

## Learn more

Standard error concerns variation of an estimate across potential samples and is not the same as SD. In base R, `sd(x)^2` and `var(x)` agree for a suitable numeric vector.
