---
id: spearman
type: walkthrough
domain: Association
aliases: spearman;rank correlation;ordinal;monotonic;rho;r_s;use Spearman
related: pearson;direction_strength;scatterplot;correlation_method
visual:
alt:
caption:
sources: https://search.r-project.org/R/refmans/stats/html/cor.html
status: VERIFIED
---
# When should I use Spearman correlation?

## Immediate answer

Use `cor(x,y,method="spearman")` for rank-based, monotonic association. Unlike Pearson’s r, it is based on the ordering of values, not their original numerical spacing.

## Use this in R

```r
data(mtcars)
x <- mtcars$wt
y <- mtcars$mpg
keep <- complete.cases(x,y)
cor(x[keep], y[keep], method="spearman")
plot(x, y, xlab="Weight (1000 lb)", ylab="Fuel economy (mpg)")
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `mtcars$wt` and `mtcars$mpg` | Paired numerical observations | Your paired columns from the same rows |
| `method="spearman"` | Rank-based correlation | Retain for monotonic/rank association |

## What to check

- Inspect a scatterplot. A strong curved relationship may be monotonic or non-monotonic.
- Tied ranks are handled by R but complicate some inference.
- Spearman association is not proof of causality.

## Interpret your results

A negative rank correlation means that larger ranks of one variable generally accompany smaller ranks of the other among recorded pairs.

## Learn more

Compare with Pearson if the question is explicitly about a linear relationship. Do not select a method solely because it produces a larger absolute number.
