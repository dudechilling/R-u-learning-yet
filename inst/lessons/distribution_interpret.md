---
id: distribution_interpret
type: walkthrough
domain: Data visualization
aliases: interpret plot;read histogram;distribution;graph pattern;observations;shape;spread;interpretation
related: histogram;range;skewness;unimodal;bimodal
visual:
alt:
caption:
sources: https://search.r-project.org/R/refmans/graphics/html/hist.html
status: VERIFIED
---
# How do I describe a graph of numerical observations?

## Immediate answer

Describe the horizontal measurement and its unit, the meaning of the vertical axis, peaks, spread, tails and unusual values. State only what the plotted records support.

## Use this in R

```r
data(iris)
hist(iris$Petal.Length, breaks=12, col="lightblue",
     main="Recorded petal lengths",
     xlab="Petal length (cm)", ylab="Flower count")
range(iris$Petal.Length)
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `iris$Petal.Length` | Recorded numeric measurements | Your numeric column |
| `breaks=12` | Display intervals | Compare another bin setting |
| `xlab` | Measurement units | Your variable and its units |

## What to check

- Check counts versus density before interpreting bar heights.
- Do not confuse axis limits with actual recorded extremes.
- Separate descriptive observations from claims about causes or other populations.

## Interpret your results

Write: "In these records, values concentrate around ___, the visible shape has ___, and the range is ___. This graph alone cannot establish ___." Substitute only observed patterns and verified numbers.

## Learn more

Use `min()`, `max()`, `range()` and `quantile()` for numerical support; do not invent values from a sketch.
