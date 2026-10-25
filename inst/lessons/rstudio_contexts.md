---
id: rstudio_contexts
type: walkthrough
collection: w2.reference.v1
domain: RStudio fundamentals
aliases: source console;source editor;run script;restart project;script versus console;execution context;save r script
related: r_objects_columns;vectors_indexing;inspect_columns;import_csv
visual:
alt:
caption:
sources: https://docs.posit.co/ide/user/ide/guide/code/execution.html
status: AUTHORED
---
# How do Source and Console execution differ?

## Immediate answer

The Console runs commands immediately in the current R session. A saved Source script preserves the commands so that you can rerun them after a fresh restart. Running a line once in Console does not save it in the script.

## Use this in R

```r
# Save these commands as an R script and run them from Source.
readings <- c(13, NA_real_, 18, 20)
length(readings)
sum(is.na(readings))
# Restart R, then source the saved script again.
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `readings` | Current R object name | A name meaningful to your project |
| `c(13, NA_real_, 18, 20)` | Four constructed observations | Your independently documented inputs |
| Source script | Saved commands | A script in your RStudio project |

## What to check

- A fresh R session does not inherit unsaved Console objects.
- Use Source to rerun saved commands; verify the object and output after restart.
- A script being saved is not proof that every line ran successfully.
- The four numbers here are constructed for teaching, not observations from the separate guided CSV.

## Interpret your results

The length is four and one value is missing. These outputs are reproducible after a restart only when the Source script is saved and executed again. The current installed Reference page cannot verify that an RStudio restart occurred.

## Learn more

Run `getwd()` to inspect the project working directory. Use `?source` for base R script execution, and the existing `inspect_columns` and `import_csv` references when a real file is involved.
