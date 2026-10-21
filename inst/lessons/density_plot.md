---
id: density_plot
type: walkthrough
domain: Data visualization
aliases: density curve;smoothed histogram;density plot;probability density;lines density
related: histogram;histogram_breaks;distribution_shape;unimodal
visual:
alt:
caption:
sources: https://search.r-project.org/R/refmans/stats/html/density.html
status: VERIFIED
---
# How do I add a density curve to a histogram?

## Immediate answer

A density curve smooths the distribution of a numerical sample. When you add it to a histogram, change the histogram to a density scale so the curve and bars describe comparable quantities.

## Use this in R

```r
data(iris)
x <- iris$Sepal.Width
hist(x, probability=TRUE, breaks=12,
     col="lightblue", main="Recorded sepal widths",
     xlab="Sepal width (cm)", ylab="Density")
lines(density(x), col="navy", lwd=2)
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `iris$Sepal.Width` | Recorded numerical values | Your numeric column |
| `probability=TRUE` | Histogram vertical scale | Keep TRUE when overlaying a density curve |
| `density(x)` | Smoothed density estimate | The same clean observations used in the histogram |

## What to check

- The height of a density curve is not the probability of that exact value.
- A density curve depends on smoothing and can hide narrow local patterns.

## Interpret your results

Describe peaks and tails on the density scale. Area, not raw curve height, represents proportions over intervals.

## Learn more

`density()` estimates a smooth distribution from data. Do not treat the resulting curve as a proven data-generating model. Compare bin and bandwidth choices.
