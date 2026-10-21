---
id: mean
type: walkthrough
domain: Descriptive statistics
aliases: average;mean;arithmetic mean;calculate average;typical value;mean function
related: median;variance;variance_sd;skewness
visual:
alt:
caption:
sources: https://search.r-project.org/R/refmans/base/html/mean.html
status: VERIFIED
---
# How do I calculate a mean in R?

## Immediate answer

Use `mean(x)` for the arithmetic average of numerical measurements. If values are missing, decide whether `na.rm=TRUE` is appropriate and report how many were excluded.

## Use this in R

```r
data(airquality)
x <- airquality$Ozone
sum(is.na(x))
mean(x, na.rm=TRUE)
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `airquality$Ozone` | Numeric observed values | Your numerical column |
| `na.rm=TRUE` | Whether to omit NA | Decide based on missing-data context |

## What to check

- Check units, numerical type and missing entries.
- The mean is sensitive to extreme observations.
- Omitting unavailable measurements can bias the summary if missingness is systematic.

## Interpret your results

The output is the average recorded ozone value among rows with usable measurements, not a verified mean for every location or season.

## Learn more

Compare `median(x,na.rm=TRUE)` and examine a histogram when extreme observations may distort a single average.
