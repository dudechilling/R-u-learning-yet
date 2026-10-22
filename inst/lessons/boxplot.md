---
id: boxplot
type: walkthrough
domain: Data visualization
aliases: boxplot;box and whisker;whiskers;median;quartiles;outliers;interpret box plot
related: quartiles;interquartile_range;outliers;histogram
visual: boxplot-explained.svg
alt: Illustrative horizontal boxplot showing the median line, lower and upper quartiles, whiskers, and one flagged potential outlier. Values are schematic.
caption: Schematic boxplot: whisker ends are not necessarily the observed minimum and maximum.
sources: https://search.r-project.org/R/refmans/graphics/html/boxplot.html
status: VERIFIED
---
# How do I make and interpret a boxplot?

## Immediate answer

Use `boxplot()` for a compact summary of a numerical distribution. The box shows the middle half of observations and the line inside usually shows the sample median.

## Use this in R

```r
data(iris)
boxplot(iris$Sepal.Length, col="lightblue",
        main="Recorded sepal length",
        ylab="Sepal length (cm)")
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `iris$Sepal.Length` | Numeric observations | Your numeric column |
| `ylab` | Units on the measured axis | Your variable and actual unit |

## What to check

- R whiskers generally end at the most extreme observations inside its 1.5-IQR fences; points beyond are flagged, not automatically wrong.
- A boxplot can hide multiple peaks that a histogram would reveal.

## Interpret your results

Describe the median, the middle 50% of recorded values (the box), and flagged observations. Do not claim a plotted difference is statistically significant on sight.

## Learn more

The quartile estimates and whisker rule should be checked before reporting exact endpoints. See `?boxplot.stats` and compare a histogram for modality.
