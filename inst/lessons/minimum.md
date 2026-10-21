---
id: minimum
type: walkthrough
domain: Descriptive statistics
aliases: minimum;lowest;smallest value;min function;min observed number
related: maximum;range;sort_values
visual:
alt:
caption:
sources: https://search.r-project.org/R/refmans/base/html/Extremes.html
status: VERIFIED
---
# How do I find the smallest recorded value?

## Immediate answer

Use `min()` for the smallest usable value. The minimum is a recorded extreme, not the lower limit of a plot axis.

## Use this in R

```r
data(iris)
min(iris$Sepal.Length, na.rm=TRUE)
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `iris$Sepal.Length` | Measurements being examined | Your numeric column |
| `na.rm=TRUE` | Ignore missing values | Keep only if excluding missing entries is appropriate |

## What to check

- Verify units and whether missing entries exist.
- Do not confuse a plotted x-axis boundary with a recorded minimum.

## Interpret your results

This output gives the smallest sepal length in the included records, measured in centimetres. It does not describe unobserved flowers.

## Learn more

Use `range(x, na.rm=TRUE)` to show both extremes, and `sort(x)` to inspect ordered observations.
