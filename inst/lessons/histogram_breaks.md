---
id: histogram_breaks
type: walkthrough
domain: Data visualization
aliases: histogram breaks;bins;number of bins;intervals;change histogram intervals;binwidth;hist breaks sequence
related: histogram;unimodal;bimodal;distribution_interpret
visual: histogram-bins.svg
alt: Two labeled histograms of identical recorded iris measurements using fewer and more intervals.
caption: Intervals are a display choice; no observations were added.
sources: https://search.r-project.org/R/refmans/graphics/html/hist.html
status: VERIFIED
---
# How do I change histogram interval widths?

## Immediate answer

The `breaks` argument determines how values are grouped into bins. A single number only suggests a bin count. A sequence specifies exact interval boundaries.

## Use this in R

```r
data(iris)
x <- iris$Sepal.Length
hist(x, breaks=10, main="Suggested bins", xlab="Sepal length (cm)")
hist(x, breaks=seq(4, 8, by=0.25),
     main="Quarter-centimetre bins", xlab="Sepal length (cm)")
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `x` | Numerical measurements | Your numeric column |
| `breaks=10` | Suggested number of bins | Another positive count |
| `seq(4, 8, by=0.25)` | Explicit bin edges in centimetres | A sequence that covers your observed minimum and maximum |

## What to check

- If specifying edges, make sure the sequence spans all included measurements.
- Narrow bins show local differences but can exaggerate noise.
- For unequal-width bins R may show density rather than raw counts; check the vertical axis.

## Interpret your results

Compare the distribution under both bin choices. The number of records is unchanged; the visual impression of modality may change.

## Learn more

Use `range(x, na.rm=TRUE)` to choose boundaries for new data. Avoid claiming there are two natural groups merely because a particular bin width shows two peaks.
