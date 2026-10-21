---
id: import_csv
type: walkthrough
domain: R fundamentals
aliases: read.csv;load csv;load spreadsheet;file.choose;import data;read data frame
related: r_objects_columns;inspect_columns;missing_values
visual:
alt:
caption:
sources: https://search.r-project.org/R/refmans/utils/html/read.table.html
status: VERIFIED
---
# How do I import a CSV into R?

## Immediate answer

Use `read.csv()` to load a CSV file into a data frame. Confirm the file, row count and column types before using it for statistical calculations.

## Use this in R

```r
# Runnable example using a temporary CSV of recorded iris data
file <- tempfile(fileext=".csv")
write.csv(iris, file, row.names=FALSE)
practice <- read.csv(file)
names(practice)
str(practice)
nrow(practice)
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `file` | CSV input file path | Use your own file path or `file.choose()` |
| `practice` | Destination data-frame name | Your preferred object name, such as `df` |
| `read.csv()` | File import operation | Check that the file uses comma-separated fields |

## What to check

- For your real file run `df <- read.csv(file.choose())`.
- Check names and types; numeric-looking text may import incorrectly.
- Do not blindly overwrite an existing data frame.

## Interpret your results

A successful import means rows and columns were read, not that all measurements or sampling assumptions are valid. Report missing entries separately.

## Learn more

Use `getwd()` to inspect the working directory and `file.exists(path)` before reading an explicitly named file. The demonstration writes only a temporary copy of built-in data.
