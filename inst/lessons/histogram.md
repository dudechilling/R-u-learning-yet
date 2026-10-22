---
id: histogram
type: walkthrough
domain: Data visualization
aliases: create histogram;make histogram;draw histogram;hist;distribution histogram;bar counts;hist plot
related: histogram_breaks;skewness;unimodal;bimodal;bar_chart;range
visual: histogram-bins.svg
alt: Two histograms of the same iris sepal measurements with different numerical interval widths; both are labeled as recorded examples.
caption: Recorded iris sepal lengths. Changing bin width changes the display, not the data.
sources: https://search.r-project.org/R/refmans/graphics/html/hist.html
status: VERIFIED
---
# How do I make a histogram for numerical measurements?

## Immediate answer

Use `hist()` to group numerical measurements into intervals. Each bar counts observations within an interval when equal-width breaks and a count axis are used.

## Use this in R

```r
data(iris)
hist(iris$Sepal.Length,
     breaks=10, col="lightblue", border="white",
     main="Recorded sepal lengths",
     xlab="Sepal length (cm)",
     ylab="Flower count")
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `iris$Sepal.Length` | Numeric observations | Your numeric column, such as `df$mpg` |
| `breaks=10` | Suggested number of intervals | A suitable count or explicit breakpoints |
| `col` | Bar fill | A readable colour |
| `main` | Graph title | What the graph really shows |
| `xlab` | Horizontal axis label | Name and unit of the measurement |

## What to check

- Use numerical, not categorical values.
- `breaks=10` requests approximately ten intervals, not necessarily exactly ten.
- Confirm whether bars show counts or densities when breaks have unequal widths.

## Interpret your results

Describe whether values cluster or spread out, where most counts occur and whether there are tails or separate peaks. Do not infer what caused any pattern.

## Learn more

Use `hist(x, plot=FALSE)` to inspect the actual `breaks` and `counts`. Choose a bar chart instead when the horizontal axis names categories.
