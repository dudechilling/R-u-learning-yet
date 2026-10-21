---
id: choose_spread
type: walkthrough
domain: Descriptive statistics
aliases: choose dispersion;standard deviation versus iqr;which spread;outliers;robust spread
related: variance_sd;interquartile_range;outliers;choose_center
visual:
alt:
caption:
sources:
status: VERIFIED
---
# When should I choose SD versus IQR?

## Immediate answer

Standard deviation describes variation around the mean and reacts strongly to extreme values. IQR describes the middle 50% and is more resistant to extremes; choose in light of the distribution and the question.

## Exam answer pattern

Inspect the distribution, choose the statistic, and justify it. For outlier-heavy samples report the median and IQR together rather than calling a few extreme values data errors.

## Use this in R

```r
data(airquality)
x <- airquality$Ozone
c(sd=sd(x,na.rm=TRUE),IQR=IQR(x,na.rm=TRUE),
  n=sum(is.finite(x)))
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `airquality$Ozone` | Numeric values | Your own numeric column |
| `na.rm=TRUE` | Missing-data handling | Use only with an explicit exclusion count |

## What to check

- SD assumes units of the recorded variable, not squared units; variance is squared.
- A robust summary does not automatically justify discarding flagged points.

## Interpret your results

State sample size, measurement unit, chosen statistic and why the graph supports the choice.

## Learn more

Comparisons across groups can require a consistent dispersion measure; do not select whichever gives a preferred result.
