---
id: grouped_boxplot
type: walkthrough
domain: Data visualization
aliases: grouped boxplot;comparative boxplot;different groups;numeric by category;boxplot formula;compare distributions
related: boxplot;mean;median;sample_size
visual:
alt:
caption:
sources: https://search.r-project.org/R/refmans/graphics/html/boxplot.html
status: VERIFIED
---
# How do I compare numeric values across categories?

## Immediate answer

Use a grouped boxplot when one variable is numerical and another identifies categories. All groups share the same measured axis, so you can compare typical values and spread.

## Use this in R

```r
data(iris)
boxplot(Sepal.Width ~ Species, data=iris,
        col="lightblue",
        main="Sepal widths by species",
        xlab="Species", ylab="Sepal width (cm)")
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `Sepal.Width` | Numerical outcome column | Your recorded measurements |
| `Species` | Grouping column | Your categories |
| `data=iris` | Data frame containing both columns | Your data frame |
| `ylab` | Measured unit | Your numeric variable and unit |

## What to check

- Confirm numerical versus categorical types.
- Record usable observations per group.
- Do not treat different-looking medians as proof of statistically significant group differences.

## Interpret your results

Each box describes the sample distribution within one species. Compare medians and variation on the shared vertical scale.

## Learn more

Use `table(iris$Species)` to check group counts. Correlation is a different question about two numerical variables.
