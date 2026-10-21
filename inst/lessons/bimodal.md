---
id: bimodal
type: concept
domain: Descriptive statistics
aliases: bimodal;two peaks;double peak;two groups;two clusters;two modes;multimodal
related: unimodal;skewness;histogram_breaks
visual: modes.svg
alt: Illustrative single-peak and two-peak density curves; no measured observations.
caption: Two peaks indicate bimodality, not necessarily two causal groups.
sources: https://search.r-project.org/R/refmans/graphics/html/hist.html
status: VERIFIED
---
# What does bimodal mean?

## Immediate answer

Bimodal means a distribution has two main peaks. Two peaks do not by themselves prove that the observations come from two populations.

## Use this in R

```r
data(faithful)
hist(faithful$eruptions, breaks=14,
     main="Recorded geyser eruptions",
     xlab="Eruption duration (minutes)", col="lightblue")
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `faithful$eruptions` | Recorded durations | Your numerical values |
| `breaks=14` | Histogram intervals | Compare other widths before making a claim |

## What to check

- Inspect whether peak count changes when bins change.
- A bimodal distribution need not be skewed.
- Separate clusters may require looking at another recorded factor; do not invent an explanation.

## Interpret your results

The recorded eruption durations form two visible clusters. Say where the peaks appear, and avoid asserting their causes from the plot alone.

## Learn more

Contrast unimodal, bimodal and multimodal. For real coursework, describe the histogram actually obtained instead of relying on a keyword.
