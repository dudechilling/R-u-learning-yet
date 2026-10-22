---
id: range
type: walkthrough
domain: Descriptive statistics
aliases: range maximum minimum spread difference highest lowest width of observations
related: minimum;maximum;interquartile_range;sort_values
visual:
alt:
caption:
sources: https://search.r-project.org/R/refmans/base/html/range.html
status: VERIFIED
---
# How do I calculate the range of measurements?

## Immediate answer

Subtract the smallest recorded value from the largest. In R, `range(x)` returns both endpoints; `diff(range(x))` returns their difference.

## Use this in R

```r
data(iris)
limits <- range(iris$Sepal.Length, na.rm=TRUE)
limits
diff(limits)
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `iris$Sepal.Length` | Recorded numeric measurements | Your data-frame column |
| `na.rm=TRUE` | Handling of missing values | Use only after deciding how to handle missingness |

## What to check

- The measurement must be numeric and use consistent units.
- The range is sensitive to extreme observations.
- Range is not the same thing as the values displayed on a graph axis.

## Interpret your results

The output from `diff(limits)` is the observed width in centimetres from the smallest to the largest sepal length. It describes these records only.

## Learn more

For iris sepal lengths the observed endpoints are 4.3 and 7.9 cm, giving a range of 3.6 cm. `IQR()` measures the middle half instead.
