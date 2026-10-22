---
id: skewness
type: concept
domain: Descriptive statistics
aliases: positive skew;positively skewed;right skew;right skewed;negative skew;left skew;skewed;skewness;how can i tell skewed;tail direction
related: histogram;distribution_shape;unimodal;bimodal;symmetry;mean_median
visual: skew-shapes.svg
alt: Three labeled illustrative density curves: negative skew has a longer left tail, symmetric has comparable tails, positive skew has a longer right tail. No observed data.
caption: Illustrative shapes, not recorded observations; tail direction defines skew.
sources: https://search.r-project.org/R/refmans/graphics/html/hist.html
status: VERIFIED
---
# What is positive or negative skew, and how can I tell?

## Immediate answer

A positively skewed distribution has a longer tail toward larger values (right). A negatively skewed distribution has a longer tail toward smaller values (left). Look at the tail, not the tallest bar.

## Use this in R

```r
data(airquality)
x <- airquality$Ozone
x <- x[is.finite(x)]
hist(x, breaks="FD", col="lightblue",
     main="Recorded ozone values", xlab="Ozone (ppb)")
abline(v=median(x), col="navy", lwd=2)
abline(v=mean(x), col="firebrick", lwd=2)
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `airquality$Ozone` | Numeric measurements | Your numeric column |
| `breaks="FD"` | Freedman-Diaconis bin selection | A defensible break rule or explicit edges |
| `xlab` | Measured variable and unit | Your recorded unit |

## What to check

- Inspect missing values and separate clusters before naming skew.
- The mean being above the median is a clue, not proof of skewness.
- Do not call a graph positively skewed merely because many values are high.

## Interpret your results

Inspect which side extends farther from the bulk of values. The longer tail is toward the larger values for right skew and toward smaller values for left skew.

## Learn more

A distribution may have multiple peaks or extreme points that complicate a simple skew label. The diagrams are theoretical models, not observed data. Try `?hist` for a numerical variable.
