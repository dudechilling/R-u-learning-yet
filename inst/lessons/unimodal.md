---
id: unimodal
type: concept
domain: Descriptive statistics
aliases: unimodal;one peak;single peak;one mode;one main cluster;modal shape
related: bimodal;skewness;histogram_breaks
visual: modes.svg
alt: One illustrative curve with a single peak beside a curve with two distinct peaks, both labelled as model shapes.
caption: Modality describes peaks, while skew describes tail direction.
sources: https://search.r-project.org/R/refmans/graphics/html/hist.html
status: VERIFIED
---
# What does unimodal mean?

## Immediate answer

Unimodal means a distribution has one main peak (one mode). The apparent number of peaks in a histogram can change when you change bin widths.

## Use this in R

```r
data(iris)
hist(iris$Sepal.Width, breaks=12,
     main="Sepal widths", xlab="Sepal width (cm)",
     col="lightblue")
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `iris$Sepal.Width` | Recorded numeric values | Your numerical measurements |
| `breaks=12` | Intervals used to reveal peaks | Compare with another suitable setting |

## What to check

- A single prominent peak can coexist with asymmetry or outliers.
- Avoid deciding from one coarse or overly narrow histogram alone.

## Interpret your results

Look for one main concentration of bars. Describe approximate shape, not a guaranteed number of groups in the population.

## Learn more

In sample data, histogram modes depend partly on smoothing and bin choice. Compare `hist(x,breaks=8)` and `hist(x,breaks=16)`.
