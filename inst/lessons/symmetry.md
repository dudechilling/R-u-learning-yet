---
id: symmetry
type: concept
domain: Descriptive statistics
aliases: symmetric;symmetry;balanced tails;approximately normal;left right mirror
related: skewness;unimodal;histogram;distribution_shape
visual: skew-shapes.svg
alt: Illustrative negative-skew, symmetric and positive-skew curves with tail directions labeled.
caption: Approximate symmetry concerns the balance of tails around the centre.
sources: https://search.r-project.org/R/refmans/graphics/html/hist.html
status: VERIFIED
---
# What makes a distribution approximately symmetric?

## Immediate answer

An approximately symmetric distribution has broadly similar shapes on either side of its centre. Perfectly mirrored observations are not required for a practical description.

## Use this in R

```r
data(iris)
hist(iris$Sepal.Width, breaks=12,
     main="Recorded sepal widths",
     xlab="Sepal width (cm)", col="lightblue")
abline(v=median(iris$Sepal.Width), col="navy", lwd=2)
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `iris$Sepal.Width` | Values whose shape you are inspecting | Your numeric column |
| `breaks` | Shape resolution | Compare a second defensible bin choice |

## What to check

- One outlier can create visible asymmetry.
- Symmetric does not mean every value is identical or normally distributed.

## Interpret your results

Compare the left and right tails and how counts decrease from the centre. Name asymmetry if one side stretches substantially farther.

## Learn more

The illustrated symmetric model is theoretical; the iris data example is recorded and need not perfectly match that curve.
