---
id: pearson
type: walkthrough
domain: Association
aliases: pearson;pearson r;product moment correlation;linear association;cor coefficient;cor(mpg,weight)
related: spearman;direction_strength;scatterplot;correlation_method
visual: scatter-correlation.svg
alt: Scatterplot of recorded mtcars vehicles with weight in 1,000 pounds and fuel economy in miles per gallon; the fitted line slopes downward.
caption: Recorded vehicle data in mtcars show a negative linear association; the line and correlation cannot establish causation.
sources: https://search.r-project.org/R/refmans/stats/html/cor.html
status: VERIFIED
---
# How do I calculate Pearson correlation?

## Immediate answer

Use `cor(x,y,method="pearson")` to summarize linear association between two paired numerical variables. A positive value indicates an upward tendency; a negative value indicates a downward tendency.

## Use this in R

```r
data(mtcars)
x <- mtcars$wt
y <- mtcars$mpg
good <- complete.cases(x,y)
cor(x[good], y[good], method="pearson")
plot(x, y, xlab="Weight (1000 lb)",
     ylab="Fuel economy (mpg)", pch=19)
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `mtcars$wt` | Predictor numeric measurements | Your first paired numeric column |
| `mtcars$mpg` | Response numeric measurements | Your second paired numeric column |
| `method="pearson"` | Linear-association statistic | Retain for Pearson’s r |

## What to check

- Keep paired measurements from the same rows.
- Inspect scatterplots for outliers, curves and restricted ranges.
- A coefficient does not establish causation or a representative sample.

## Interpret your results

Report the sign and magnitude for these recorded vehicles. The negative value reflects an inverse linear association between weight and fuel economy in this dataset.

## Learn more

For monotonic rank relationships `cor(x,y,method="spearman")` is an alternative; it answers a different question. A significance test needs additional assumptions: see `cor.test()`.
