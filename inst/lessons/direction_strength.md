---
id: direction_strength
type: walkthrough
domain: Association
aliases: interpret r;positive negative correlation;strong weak;coefficient sign;relationship direction;correlation magnitude
related: pearson;spearman;scatterplot;correlation_causation
visual: scatter-correlation.svg
alt: Scatterplot of recorded mtcars vehicles with weight in 1,000 pounds and fuel economy in miles per gallon; the fitted line slopes downward.
caption: Recorded vehicle data in mtcars show a negative linear association; the line and correlation cannot establish causation.
sources: https://search.r-project.org/R/refmans/stats/html/cor.html
status: VERIFIED
---
# How do I interpret the sign and size of a correlation coefficient?

## Immediate answer

A negative correlation means larger values of one variable tend to appear with smaller values of the other. A positive correlation means they tend to rise together. The absolute size summarizes the strength of the association measured by the chosen method.

## Use this in R

```r
data(mtcars)
r <- cor(mtcars$wt, mtcars$mpg)
r
plot(mtcars$wt, mtcars$mpg, pch=19,
     xlab="Weight (1000 lb)", ylab="Fuel economy (mpg)")
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `mtcars$wt` | First paired numeric variable | Your predictor or comparison column |
| `mtcars$mpg` | Second paired numeric variable | Your second numeric column |
| `cor()` | Pearson correlation by default | Use `method="spearman"` for rank association when justified |

## What to check

- Magnitude labels such as weak and strong depend on the field and design.
- A correlation close to zero can hide a curved relationship.
- Correlation does not identify cause and effect.

## Interpret your results

State the sign, estimated magnitude, what variables were paired and the population limitation. Say "a negative association was observed" rather than "weight causes lower fuel economy" based on r alone.

## Learn more

R reports an estimate between -1 and +1. For Pearson, +1 and -1 indicate a perfect linear relationship in the observed sample; 0 means no linear correlation, not necessarily no relationship.
