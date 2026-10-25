---
id: histogram_interpret
type: walkthrough
collection: w2.reference.v1
domain: Data visualization
aliases: interpret histogram;right closed bins;left closed bins;boundary inclusion;histogram counts;histogram meaning
related: histogram;histogram_breaks;mean;describe_numeric;distribution_shape
visual: histogram-bins.svg
alt: Existing two-panel histogram artwork of 150 recorded iris sepal lengths in centimetres, comparing broader and narrower interval choices. Both panels use R's default right-closed breaks and count axes; this is not the four-temperature teaching dataset.
caption: Existing iris illustration, preserved unchanged. The plotted broad panel requests breaks=8, while the narrow panel explicitly uses 0.25 cm bins. Separate numerical boundary comparisons below use expressly stated breaks and must not be mistaken for the broad panel.
sources: https://search.r-project.org/R/refmans/graphics/html/hist.html
status: AUTHORED
---
# What can a histogram tell me about numeric measurements?

## Immediate answer

A histogram counts or represents the density of numeric measurements across intervals. Its horizontal axis is the measured variable and unit; its vertical axis must be inspected. Interval width and whether a boundary belongs to the left or right bin can change counts and apparent shape.

## Use this in R

```r
# 150 iris sepal lengths, NOT the four synthetic temperatures.
x <- iris$Sepal.Length
right <- hist(x, breaks=seq(4, 8, by=1),
              right=TRUE, include.lowest=TRUE, plot=FALSE)
left <- hist(x, breaks=seq(4, 8, by=1),
             right=FALSE, include.lowest=TRUE, plot=FALSE)
c(right_closed_5_to_6=right$counts[2],
  left_closed_5_to_6=left$counts[2])
# Right (5,6] has 57 flowers; left [5,6) has 61.
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `iris$Sepal.Length` | Built-in sepal lengths (cm) | A documented numeric measurement |
| `seq(4, 8, by=1)` | Explicit interval boundaries | Breakpoints covering your recorded range |
| `right=TRUE` | Right-closed (a,b] bins | Set FALSE only with a clearly labelled alternative |

## What to check

- The preserved existing SVG is right-closed. Do not relabel it as left-closed.
- For narrower 0.25 cm breaks, right-closed (5,5.25] has 13 observations; left-closed [5,5.25) has 23.
- Built-in `iris` has 150 flowers; `faithful` has 272 eruption records; neither is the four-reading numeric teaching example.
- A suggested count such as `breaks=8` may be adjusted by R. Inspect `hist(x,plot=FALSE)$breaks`.
- Interpretation of observed shape cannot establish causal mechanisms or population representativeness.

## Interpret your results

Changing closure with identical data and breakpoints assigns boundary values differently. The displayed counts for (5,6] and [5,6) are 57 and 61 respectively, not evidence that observations were added or removed. State which convention the numerical example uses.

## Learn more

Open the existing `histogram` and `histogram_breaks` pages for plotting and interval-width choices. Use native `?hist` for R's installed graphics behavior.
