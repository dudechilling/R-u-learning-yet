---
id: distribution_shape
type: concept
domain: Descriptive statistics
aliases: distribution shape;interpret histogram;number peaks;skewness;shape;cluster;tail;unimodal bimodal
related: histogram;skewness;unimodal;bimodal;histogram_breaks
visual: modes.svg
alt: Illustrative one-peak and two-peak density models showing what to look for in modality.
caption: Shape is an observed pattern, not a hypothesis test.
sources: https://search.r-project.org/R/refmans/graphics/html/hist.html
status: VERIFIED
---
# How do I describe the shape of a distribution?

## Immediate answer

Describe where observations cluster, how many peaks are visible, whether one tail is longer, and whether there are unusual observations. Use the actual graph, not a memorized label.

## Use this in R

```r
data(faithful)
hist(faithful$eruptions, breaks=14,
     main="Eruption durations", xlab="Minutes", col="lightblue")
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `faithful$eruptions` | Numeric observations to describe | Your numerical column |
| `breaks=14` | Grouping of recorded values | Compare a second suitable interval choice |

## What to check

- Identify whether the vertical axis shows counts or density.
- Look for separate peaks before labeling skewness.
- Do not assume plotted groups have known causes.

## Interpret your results

An interpretation pattern is: "The observed distribution appears ___ because ___; the plot alone cannot establish ___." Fill the blanks with your actual observations.

## Learn more

Compare with `unimodal`, `bimodal` and `skewness` references. A histogram can conceal grouping by another categorical variable.
