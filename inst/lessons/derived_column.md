---
id: derived_column
type: walkthrough
domain: R fundamentals
aliases: new column;add column;derived variable;transform;df$column<-;calculated values
related: r_objects_columns;inspect_columns;statistical_variable
visual:
alt:
caption:
sources: https://search.r-project.org/R/refmans/base/html/Extract.html
status: VERIFIED
---
# How do I add a calculated column to a data frame?

## Immediate answer

Assign a computed vector to `data_frame$new_name`. This adds or replaces a column in the data frame; it does not change the CSV file saved on disk.

## Use this in R

```r
data(mtcars)
practice <- mtcars
practice$mpg_per_1000lb <- practice$mpg / practice$wt
head(practice[c("mpg","wt","mpg_per_1000lb")])
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `practice` | Data frame to modify | Use a copy of your own data |
| `mpg_per_1000lb` | New derived column name | A name that states your transformation |
| `practice$mpg / practice$wt` | Numerical operation | A meaningful calculation with compatible units |

## What to check

- Check that required source columns exist and are numeric.
- Verify denominator is not zero or missing before division.
- A derived ratio is not a directly recorded observation and may not be useful for your research question.

## Interpret your results

The new column shows a computed ratio for each recorded vehicle. It is not a new vehicle observation or population estimate.

## Learn more

`names(practice)` confirms the new column exists. For your own CSV, consider keeping `df_original <- df` first rather than overwriting raw evidence.
