---
id: vectors_indexing
type: walkthrough
collection: w2.reference.v1
domain: R fundamentals
aliases: vectors;index R values;logical indexing;is.na;function arguments;NA versus zero;subsetting
related: r_objects_columns;inspect_columns;missing_values;mean
visual:
alt:
caption:
sources: https://search.r-project.org/R/refmans/base/html/Extract.html
status: AUTHORED
---
# How do vectors, functions and indexing work in R?

## Immediate answer

A vector stores values of a common basic type. R indexing starts at 1. A function such as `length()` returns a result, and an argument such as `na.rm` changes the function's behavior. Missing `NA` is not the number zero.

## Use this in R

```r
x <- c(13, NA_real_, 18, 20)
length(x)
x[c(1, 3, 4)]
is.na(x)
x[!is.na(x)]
mean(x)              # Missing until handled
mean(x, na.rm=TRUE)  # Only after deciding to omit NA
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `x` | Teaching numeric vector | A verified numeric column or a separate vector |
| `c(1, 3, 4)` | Positions selected | Positions actually present in your data |
| `!is.na(x)` | Logical selection | A documented eligibility rule |
| `na.rm=TRUE` | Omission argument | Use only with a defensible missingness decision |

## What to check

- `x[1]` selects the first value; `x[0]` selects no value.
- `is.na(x)` identifies missing entries, whereas `x == 0` compares to zero.
- Indexing and `mean()` do not document units, sampling design or missingness causes.
- A result after `na.rm=TRUE` must state the denominator and exclusions.

## Interpret your results

The constructed vector has four entries and three observed readings. Its observed-case mean is 17 only after the exclusion decision. This teaching vector is separate from the imported L2 guided CSV even when their values happen to match.

## Learn more

Use `?Extract`, `?is.na` and `?mean` for authoritative R behavior. Then open `missing_values` to compare explicit missingness decisions.
