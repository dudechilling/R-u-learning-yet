---
id: bar_chart
type: walkthrough
domain: Data visualization
aliases: bar chart;bar graph;categorical graph;counts;frequency table;barplot;category labels
related: frequency_table;histogram;categorical_quantitative
visual:
alt:
caption:
sources: https://search.r-project.org/R/refmans/graphics/html/barplot.html
status: VERIFIED
---
# How do I make a bar chart of category counts?

## Immediate answer

Use `table()` to count named categories, then `barplot()` to draw them. Unlike a histogram, categories are separate labels rather than intervals on a numerical scale.

## Use this in R

```r
data(iris)
counts <- table(iris$Species)
barplot(counts, col="lightblue",
        main="Recorded flower categories",
        xlab="Species", ylab="Flower count")
counts
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `iris$Species` | Categorical observations | Your category column |
| `main` | Plot title | Describe the categories in your records |
| `ylab` | Vertical-axis label | Count or proportion, whichever you plotted |

## What to check

- Count original observations, not rows of a pre-aggregated frequency table.
- Identify missing category labels and how they are handled.
- Zero should generally be visible as the bar baseline for count comparisons.

## Interpret your results

Each bar height counts recorded flowers in that species. In the sample iris dataset, each of three categories has 50 observations; that does not show their relative frequency in nature.

## Learn more

Use `prop.table(counts)` for proportions. With summary counts already supplied use those directly, not `table()` on the summary table.
