---
id: choose_center
type: walkthrough
domain: Descriptive statistics
aliases: choose mean median;central tendency skew outlier;robust center;when use median
related: mean;median;skewness;choose_spread
visual:
alt:
caption:
sources: https://search.r-project.org/R/refmans/base/html/mean.html
status: VERIFIED
---
# When should I use the mean rather than the median?

## Immediate answer

For an approximately symmetric distribution without strong outliers, a mean can be a useful centre. For a markedly skewed or outlier-heavy distribution, a median often describes a typical observation more robustly.

## Exam answer pattern

Inspect a graph and explain whether extremes or asymmetry affect the mean. Name the chosen statistic and why it suits these data; do not use one rule blindly.

## Use this in R

```r
data(airquality)
x <- airquality$Ozone
c(missing=sum(is.na(x)),mean=mean(x,na.rm=TRUE),median=median(x,na.rm=TRUE))
hist(x,main="Recorded ozone",xlab="Ozone (ppb)")
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `airquality$Ozone` | Recorded numeric values | Your numeric column |
| `na.rm=TRUE` | Missing-value exclusion | Report how many values are omitted |

## What to check

- A median can also hide two peaks; inspect the distribution first.
- The choice depends on the question, the population and sampling, not only skew.

## Interpret your results

Report the sample centre and how it relates to skew or extreme points. A large difference between mean and median is a clue, not a proof of the distribution's shape.

## Learn more

For reporting a population mean as the scientific target, a sample mean may remain the estimand even when data are skewed; uncertainty and methods still matter.
