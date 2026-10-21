# R-u-learning-yet

**An offline, assignment-first reference library inside RStudio.**

Start with the question in your assignment. The package finds a method, shows
an immediate explanation and ordinary R code, identifies what you must change,
and gives optional background and practice. The package does **not** solve
your dataset or validate your study assumptions for you.

## Release status

This version is a **local development candidate**, not the public GitHub
`main` branch. Install the exact reviewed QA source archive provided
separately after approval. Do not expect the current GitHub installation
command to provide the new Viewer pages.

The package requires R 4.1 or newer and recommends the existing
`rstudioapi` package to open the Viewer and Source editor. Core references
continue to work offline without Quarto, Shiny, a chatbot or a server.

## Search from RStudio

```r
library(rulearn)

ru_find("How can I tell if my data are skewed?")
ru_find("What does unimodal mean?")
ru_find("How do I create a stem and leaf plot?")
ru_find("How do I create variables?")
ru_find("How do I calculate standard deviation?")
```

In RStudio, these calls open **local HTML** in the existing **Viewer** pane,
rather than printing an article into the Console. The page includes:

- **Quick answer**: the immediate response in plain language.
- **Use this in R**: copyable ordinary R code using a built-in dataset.
- **What to edit**: table of columns and arguments to replace.
- **What to check** and **Interpret your results**: validity and limits.
- **Learn more**: extended instruction, collapsed until needed.

The code-copy control does **not** execute R commands. If clipboard access
fails, it selects the code and asks you to press Ctrl+C. Test clipboard
behaviour in Windows RStudio before assuming it works.

```r
ru_open("skewness")         # the relevant local reference in Viewer
ru_guide("histogram")      # one formatted walkthrough
ru_edit("histogram", mode="quick")  # editable script in Source editor
ru_topics()                # catalogue with content status
```

References return R objects **invisibly**. For an ordinary terminal outside
RStudio, call `ru_text("How do I calculate a mean?")` to request short text
explicitly. In a normal terminal `ru_find()` still returns structured search
results; it does not write long articles to the Console.

## Search versus coverage

The local coverage index currently lists **120 scoped topics**. The initial
candidate supplies **31 reviewed compact lessons** (with executable examples)
and maintains the earlier 46 longer walkthroughs, 21 native concept articles,
and 11 R-function articles. The remaining ledger entries are clearly marked
`NEEDS_REVIEW` or `DISCOVERED`. An indexed topic is not automatically a
finished instruction page.

Older walkthroughs that have not been rewritten show a **clear compatibility
notice** rather than claiming to teach ordinary R code. Their original
`ru_apply()` methods and standalone example scripts remain available for
existing users. The package does not expand the calculation interface.

```r
help("stationarity", package="rulearn")   # original native R Help
?hist                                  # official R hist() help
ru_edit("skewness", open=FALSE)         # new compact native R script
```

A reference gives a defensible method to consider; it cannot verify your
sampling, measurement units, independence assumptions or interpretations.

## Content and reproducibility

Compact lesson sources are in `inst/lessons/*.md`. Each contains a single
structured question, immediate answer, native R code, edit instructions,
checks, interpretation, optional explanation and source URL. The Viewer
renders these installed files into temporary HTML; no duplicated page text
is committed.

The small `R/` directory implements reference lookup and rendering. The
`inst/www/` directory contains local CSS, minimal copy-button JavaScript and
four purposeful SVG figures. Figures can be regenerated with
`Rscript scripts/generate-figures.R`. Existing long-form material remains
in `inst/guides/` and `inst/examples/`; the legacy Quarto site remains
optional. The public `inst/extdata/coverage.csv` ledger contains topic
status but **not** private coursework or filenames.

Detailed architectural decisions and evidence limits live in
[research-and-decision.md](research-and-decision.md). See
[methodology.md](methodology.md) for editorial and statistical safeguards.

## Tests and redistribution

Run `R CMD build .` from a parent folder and then
`R CMD check --no-manual rulearn_0.4.0.tar.gz` on the built archive.
Also run the Quarto site and local-rendering test suites when updating pages.
Windows Viewer navigation and clipboard behaviour require a supervised
Windows RStudio test; automated HTML checks are not a substitute.

The repository has **no selected redistribution licence**. No licence
permissions are inferred from public access. Do not redistribute course
materials, graded work, instructor slides or student identifiers.