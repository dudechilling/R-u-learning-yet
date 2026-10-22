---
id: maximum
type: walkthrough
domain: Descriptive statistics
aliases: maximum;highest;largest;max observed
related: minimum;range;sort_values
visual:
alt:
caption:
sources: https://search.r-project.org/R/refmans/base/html/Extremes.html
status: VERIFIED
---
# How do I find the largest recorded value?

## Immediate answer

Use `max()` for the largest recorded usable number. It is an observed extreme, not an upper confidence bound.

## Use this in R

```r
data(iris)
max(iris$Sepal.Length, na.rm=TRUE)
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `iris$Sepal.Length` | The values being measured | Your numeric column |
| `na.rm=TRUE` | Drop missing entries for this calculation | Report missingness rather than treating NA as zero |

## What to check

- Check whether units and measurement ranges make sense.
- Do not assume the largest observation is the largest possible value.

## Interpret your results

The result is the maximum recorded sepal length, in centimetres, among the rows used.

## Learn more

For a full spread summary, compare `min()`, `max()` and `diff(range(x))`.
