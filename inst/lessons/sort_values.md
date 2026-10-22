---
id: sort_values
type: walkthrough
domain: Descriptive statistics
aliases: sort scores in order;rank smallest largest;ascending;descending;sort data vector
related: minimum;maximum;range;histogram
visual:
alt:
caption:
sources: https://search.r-project.org/R/refmans/base/html/sort.html
status: VERIFIED
---
# How do I sort numerical observations?

## Immediate answer

Use `sort()` to place numbers in ascending order. Use `decreasing=TRUE` for largest first. Sorting changes the order of a copy, not the recorded values.

## Use this in R

```r
data(iris)
ordered <- sort(iris$Sepal.Length)
head(ordered)
tail(ordered)
sort(iris$Sepal.Length, decreasing=TRUE)
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `iris$Sepal.Length` | Recorded numbers to sort | Your numeric column, for example `df$mpg` |
| `decreasing=TRUE` | Direction of order | Remove or set FALSE for smallest first |

## What to check

- Check that the column is numerical and note any missing values.
- To sort entire rows while keeping related columns together, use `order()` on the data frame instead.

## Interpret your results

The first value in `ordered` is the smallest recorded sepal length. Sorting does not calculate a typical value or say how many times a value occurs.

## Learn more

For whole-table sorting use `iris[order(iris$Sepal.Length), ]`. Read `?sort` and `?order` for ties and missing-value handling.
