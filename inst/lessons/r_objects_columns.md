---
id: r_objects_columns
type: walkthrough
domain: R fundamentals
aliases: create variables;create varibles;assign objects;df$mpg;df$weight;<-;extract column;select column;object;store values
related: derived_column;statistical_variable;import_csv;inspect_columns
visual:
alt:
caption:
sources: https://search.r-project.org/R/refmans/base/html/assignOps.html
status: VERIFIED
---
# How do I create R objects from data-frame columns?

## Immediate answer

If your CSV is already in `df` and includes columns `mpg` and `weight`, use `mpg <- df$mpg` and `weight <- df$weight`. `$` selects the named column; `<-` stores those values in a named R object.

## Use this in R

```r
# Built-in demonstration; your imported df can stay unchanged
practice <- mtcars
mpg <- practice$mpg
weight <- practice$wt
length(mpg)
length(weight)
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `practice` | Example data frame | Your already loaded data frame, such as `df` |
| `practice$mpg` | Fuel economy column | `df$mpg` if your file has that exact column |
| `practice$wt` | Weight example in mtcars | `df$weight` if your file uses weight |
| `mpg`, `weight` | New object names | Names meaningful to you |

## What to check

- Use `names(df)` to check exact spelling and capitalization.
- The built-in mtcars column is `wt`, not `weight`.
- Creating an R object is not the same as adding a column to the original data frame.

## Interpret your results

You should obtain one numeric entry per recorded row, provided both columns exist and there are no type problems. This operation does not calculate a mean or correlation.

## Learn more

To create a new column within a data frame place `df$column` on the left of `<-`. Native help: `?assignOps` and `?Extract`.
