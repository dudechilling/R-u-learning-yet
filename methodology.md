# How the problem bank is built and checked

## Purpose

Start with a question a person might ask about data. Identify the needed evidence, choose a method, run it in RStudio, and explain what the result does—and does not—establish.

These guides are **methods**, not answer keys. They can be applied to compatible tables with other variable names, but no code can guarantee that all assumptions hold for an unknown dataset.

## Where the data come from

Most examples load named datasets included with R, such as `iris`, `airquality`, `cars`, `mtcars`, `faithful`, `PlantGrowth`, `sleep`, `Nile`, and `Titanic`. These data are fetched from R's `datasets` package on the student's computer, not copied into this repository.

The optional `penguins` dataset uses the separately installed `palmerpenguins` R package; its original Palmer Station LTER dataset is available under CC0. An example that derives a new variable from a real dataset must identify that derived value and not call it a recorded observation.

Some theoretical questions require hypothetical probability parameters or transformations. Label these as **model assumptions** or **constructed demonstrations**, not observed data. Do not silently replace missing observations with invented values.

## Standard shape of a problem

Each guide should contain:

1. A realistic question in everyday language.
2. The evidence needed: which variables, units, counts, or design conditions must be supplied.
3. A clear decision about why this method fits, and when it does not.
4. A named dataset and a runnable, standalone R script.
5. A plain-language interpretation, distinguishing descriptive and inferential claims.
6. A reusable `ru_apply()` command that works with independently named columns.
7. An alternative approach for a changed question or missing input.

Use `ru_plan()` for explicit information-dependent routes. Inputs not supplied are **unknown**, not automatically absent.

## Reproducibility and public material

`inst/examples/` contains one tested script per question. `problems/` contains its human-facing explanation. `R/` holds reusable console search, input validation, plotting and calculation functions. Index tables in `inst/extdata/` connect those elements.

No machine logs, temporary status files, rendered duplicates or raw copies of built-in datasets belong in the repository.

Do not upload restricted documents, personal records, nonpublic datasets, or unpublished assessment solutions. Do not claim ownership of or redistribute third-party material without rights. Keep an attributable license for sources that require it; no license is currently selected for contributions to this repository.

## Graph standards

Use explicit axis labels and units, and report what is counted. Add counts with `text()`, distinguish observed points from fitted lines with `legend()` and line types, and use `col` only to support an already interpretable plot. Grouping should never hide unequal sample sizes or missing values. Fitted lines must not imply causation or justified extrapolation.

## Tests before publishing

- Install the package in a clean R library and verify the help pages and exports.
- Run every standalone example.
- Check every problem page has a matching example and that all relative links resolve.
- Test functions against other data frames and renamed columns, not just the demonstration dataset.
- Test invalid input types, nonexistent columns, missing values, frequency weights, pairing requirements, and model assumptions.
- Confirm sampling code leaves the caller's random state unchanged.
- Run `R CMD check --no-manual` without errors, warnings or notes.
- Inspect the public Git tree for private or unintended references before updating the default branch.

Passing software tests means the code functions as tested. It does not prove every inference is appropriate in every real study.
