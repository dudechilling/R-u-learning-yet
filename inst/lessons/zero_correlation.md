---
id: zero_correlation
type: walkthrough
domain: Association
aliases: r zero;correlation zero;no linear correlation;nonlinear relationship;pearson zero
related: pearson;direction_strength;scatterplot
visual:
alt:
caption:
sources: https://search.r-project.org/R/refmans/stats/html/cor.html
status: VERIFIED
---
# Does Pearson correlation of zero prove no relationship?

## Immediate answer

No. Pearson r=0 means no linear correlation in the observed pairs. A strong curved association can still exist, so inspect a scatterplot before concluding that variables are unrelated.

## Exam answer pattern

Distinguish the narrower claim of no linear association from the broader claim of statistical independence. Describe a curved pattern that Pearson r cannot summarize.

## Use this in R

```r
x <- -5:5                     # Constructed teaching example
y <- x^2                      # Explicit nonlinear model
cor(x,y,method="pearson")
plot(x,y,pch=19,col="#28627A",main="Curved constructed relation",
     xlab="Constructed x",ylab="x squared")
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `x <- -5:5` | Constructed numeric inputs | Your paired recorded predictor |
| `y <- x^2` | Demonstration model | Your observed response, not squared unless justified |

## What to check

- Nonlinear dependence can coexist with Pearson r exactly zero.
- Outliers and restricted ranges can also change a correlation estimate.
- Do not infer causality from a coefficient.

## Interpret your results

In a symmetric U-shaped relationship, larger positive and negative x values both give larger y values; positive and negative linear tendencies cancel.

## Learn more

An estimate near zero is not a formal proof of independence. Consider suitable nonlinear models only when justified by the data and study design.
