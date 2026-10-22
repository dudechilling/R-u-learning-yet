---
id: quartiles
type: walkthrough
domain: Descriptive statistics
aliases: quartiles;Q1 Q2 Q3;25th percentile;median;middle half;quantile probabilities
related: median;interquartile_range;boxplot;percentiles
visual:
alt:
caption:
sources: https://search.r-project.org/R/refmans/stats/html/quantile.html
status: VERIFIED
---
# How do I calculate the first, second and third quartiles?

## Immediate answer

Use `quantile(x, probs=c(0.25, 0.5, 0.75))` to find the quartiles. These cut points divide the ordered measurements into quarters under R’s default calculation convention.

## Use this in R

```r
data(iris)
quantile(iris$Sepal.Length,
         probs=c(0.25,0.50,0.75),na.rm=TRUE)
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `iris$Sepal.Length` | Numerical values being summarized | Your numeric column |
| `probs` | Quantile fractions | 0.25, 0.50, 0.75 for Q1, median and Q3 |
| `na.rm=TRUE` | Missing-value handling | Retain only when justified |

## What to check

- Quartile conventions differ across software and textbooks.
- Check R `?quantile` for `type=7` default.
- Do not infer observations outside the measured sample.

## Interpret your results

Q1 is the value below which roughly a quarter of recorded measurements lie; Q2 is the median; Q3 marks the upper three-quarter cutoff. The middle 50% lies between Q1 and Q3.

## Learn more

You can calculate `IQR(x)` to describe the middle-half spread. For iris sepal lengths, R’s default quartiles are about 5.1, 5.8 and 6.4 cm.
