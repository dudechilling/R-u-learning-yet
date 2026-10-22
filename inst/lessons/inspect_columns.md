---
id: inspect_columns
type: walkthrough
domain: R fundamentals
aliases: describe dataset;describe iris dataset;inspect dataset;names;str;head;summary;columns;types;rows;number of observations
related: import_csv;r_objects_columns;missing_values;statistical_variable
visual:
alt:
caption:
sources: https://search.r-project.org/R/refmans/utils/html/str.html
status: VERIFIED
---
# How do I inspect or describe a dataset in R?

## Immediate answer

Use `names()` and `str()` to see the columns and their data types, then `head()` and `summary()` to understand the recorded values. Use `nrow()` for the number of rows.

## Use this in R

```r
data(iris)
names(iris)
str(iris)
head(iris)
nrow(iris)
summary(iris)
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `iris` | Data frame being inspected | Your loaded data frame, for example `df` |
| `names()` | Column names | Check exact spelling before selecting a column |
| `str()` | Column types and sample values | Look for numeric, factor and character |

## What to check

- A row is not always an independent study unit.
- Column types do not prove measurement units or the meaning of categories.
- A sampled dataset does not necessarily represent the population.

## Interpret your results

State how many rows and columns the dataset has, identify the numeric and categorical fields, and describe the recorded units only when the documentation supports them.

## Learn more

Use `?iris` for built-in dataset provenance, and `sum(is.na(x))` to count missing values. A quick summary does not verify collection methods.
