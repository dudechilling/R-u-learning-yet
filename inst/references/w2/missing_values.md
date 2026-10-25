---
id: missing_values
type: walkthrough
collection: w2.reference.v1
domain: Data quality and analysis
aliases: missing data;NA;exclude missing;complete cases;na.rm;missingness;observed case
related: vectors_indexing;mean;inspect_columns;import_csv;describe_numeric
visual: observed-missing-flow.svg
alt: Four constructed Celsius readings are 13, missing, 18 and 20. One reading is missing; after an explicit exclusion decision, three observed readings yield mean 17 degrees Celsius.
caption: Constructed teaching values only. Three observed readings and one missing record; excluding the missing entry changes the denominator from four to three, not the source data.
sources: https://search.r-project.org/R/refmans/base/html/NA.html;https://search.r-project.org/R/refmans/stats/html/na.fail.html
status: AUTHORED
---
# What should I do with missing numerical values?

## Immediate answer

Count missing entries, investigate their cause, and record an explicit decision before computing an observed-case summary. An `NA` is unknown or unavailable, not zero; `na.rm=TRUE` omits entries rather than repairing the missing measurement.

## Use this in R

```r
# Constructed teaching measurements; assume degrees Celsius are declared.
x <- c(13, NA_real_, 18, 20)
n_raw <- length(x)
n_missing <- sum(is.na(x))
n_observed <- sum(!is.na(x))
# Only after deciding that an observed-case description is appropriate:
observed_mean <- mean(x, na.rm=TRUE)
c(raw=n_raw, missing=n_missing, observed=n_observed,
  observed_mean=observed_mean)
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `x` | Constructed numeric teaching vector | Your actual verified outcome column |
| `n_missing` | Count of entries marked `NA` | Report separately for each outcome |
| `na.rm=TRUE` | Complete-case omission for this one outcome | Apply only after a recorded consent or design decision |

## What to check

- Never silently substitute zero or infer why a value is absent.
- Report four raw records, one missing entry and three usable readings for this example.
- Record the unit and source separately; a variable named `reading` does not establish Celsius.
- Describe missingness without claiming that observed cases represent unmeasured ones.
- This compact page is newly authored and distinct from the older `missing_values` Quarto guide and native example, whose rights and review state remain separate.

## Interpret your results

For these four constructed readings, the mean of the three observed values is 17 degrees Celsius if their units were declared and omission was justified. The result is descriptive only; it does not establish missing-at-random assumptions, independence or a population estimate.

## Learn more

For a supplied data frame, use `sum(is.na(df$reading))` and verify exact column names. The separately available legacy `missing_values` guide uses a different example with `airquality$Ozone`; do not treat that example as these four values.
