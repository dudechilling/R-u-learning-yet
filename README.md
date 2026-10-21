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

The local coverage index contains **158 scoped topics**. This candidate
provides **61 source-reviewed compact lessons**, of which 47 include
executable ordinary R examples and 14 provide conceptual study guidance
without unnecessary code. The remaining 97 indexed topics consist of
53 `AUTHORED` but unverified drafts, 8 `NEEDS_REVIEW`, and 36 `DISCOVERED`
topics without finished lessons. An indexed topic is not a published lesson.

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

Compact lesson sources are in `inst/lessons/*.md`. Each contains an
original question, immediate answer, validity checks, bounded interpretation
and optional explanation. Computational lessons include native R and an edit
table. Concept-only study cards contain no fake calculation.
Public sources are cited only where verified; source-slide anchors remain
in the private QA evidence.

The `R/` directory implements reference lookup and local rendering.
The `inst/www/` directory supplies a local shared palette, copy control
and five purpose-built SVG diagrams. Regenerate figures with
`Rscript scripts/generate-figures.R`. The 46 older long-form
walkthroughs remain as compatibility material. Unfinished broader
curriculum and Quarto-specific output remain outside the verified
candidate, with status retained in the catalogue.

## Tests and redistribution

Run `R CMD build .` from a parent folder and then
`R CMD check --no-manual rulearn_0.4.2.tar.gz` on the built archive.
Quarto-specific rendering remains unverified in Phase 1 because its CLI
was unavailable in the m710 environment; the offline R package itself does
not require Quarto.
Windows Viewer navigation and clipboard behaviour require a supervised
Windows RStudio test; automated HTML checks are not a substitute.

The repository has **no selected redistribution licence**. No licence
permissions are inferred from public access. Do not redistribute course
materials, graded work, instructor slides or student identifiers.