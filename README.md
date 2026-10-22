# R-u-learning-yet

**An offline statistics and R learning library, from first steps to selected research workflows.**

Start with a question. Find a compatible method. Check its assumptions. Inspect an original worked example, edit ordinary R code, and interpret its uncertainty and limits. The package is named `rulearn`.

**Version 0.4.2.9001.** The original RU code and educational content have source-specific licences. Automated package checks have passed on Linux. Manual Windows RStudio Viewer and clipboard checks remain separate. No illustration is presented as an authentic interface screenshot.

## Install directly from GitHub main

Run these commands in RStudio with internet access for installation:

```r
install.packages("remotes")
remotes::install_github("dudechilling/R-u-learning-yet")
library(rulearn)
```

The package shall open its local landing page automatically in a supported
interactive RStudio session. Run ru_home() to reopen it.
Set options(rulearn.auto_home = FALSE) before library(rulearn) to disable
automatic opening. Installed statistical content runs offline; installation
from GitHub requires an internet connection.

## What the candidate contains

This release contains **84 compact lessons: 68 with executable native R examples and 16 conceptual references**. Its coverage register contains **174 topic rows**. Of these, 84 carry the recorded `VERIFIED` content label, 48 are `AUTHORED`, 6 `NEEDS_REVIEW`, and 36 `DISCOVERED`. These legacy status fields are retained for compatibility. Learning paths map unfinished work to `IN_REVIEW` or `PLANNED`.

The latest release adds ten verified workflows. Their numerical examples have separate mathematical checks and frozen routing cases. Existing labels are not a claim that every lesson has received a new independent human or legal review. Software verification, source rights and actual IDE acceptance are distinct.

The four learning paths cover:

| Path | Current scope |
| --- | --- |
| Beginner | R objects, inspecting and importing data, variable types, summaries, frequencies and plots |
| Core | Probability, distributions, sampling, CLT, mean and proportion intervals, t-test designs, hypothesis interpretation and uncertainty |
| Applied | Simple least-squares regression, residual and influence diagnostics, and Welch one-way ANOVA |
| Research | Grouped binomial logistic regression, iid mean bootstrap with percentile intervals, and Holm familywise multiple-testing adjustment |

These are bounded workflows, not a claim that all advanced statistics is available. Mixed models, complex survey inference, advanced spatial/time-series methods and unimplemented estimators remain unsupported. Named incompatible methods must not receive a superficially similar substitute.

Inspect the installed record rather than relying on a copied count:

```r
topics <- ru_topics()
nrow(topics)
table(topics$content_status)
```

## Start with a question

```r
ru_find("How do I create a histogram?")
ru_find("How do I run a Welch t test for two independent groups?")
ru_find("Fit binomial logistic regression to independent grouped successes and failures.")
ru_find("Adjust a prespecified family of p-values with the Holm method.")
```

Search is deterministic and local. Compatibility checks run before ranking. Search may return no match when the model, operation, design or interpretation is unsupported or contradictory. A reference is not a solver for an unseen dataset and does not supply missing study assumptions.

Results return invisibly as data frames. Assign the result to inspect it:

```r
hits <- ru_find("bootstrap_mean", n = 3L)
hits
```

## Read and edit native R

The home links to Start, a guided offline **Tutorials** page, local references, method coverage, learning paths, accessibility help and licence notices. Two Viewer walkthroughs demonstrate a histogram using built-in data and a synthetic 90% mean confidence interval, with copyable R code, expected results and interpretation. A computational page presents the question, method choice, assumptions, numbered procedure, original worked case, native code, editable inputs, interpretation and common mistakes.

```r
ru_open("mean_confidence_interval")
ru_open("glm_binomial")
ru_edit("bootstrap_mean", open = FALSE)
```

`ru_edit()` writes an editable script. The Viewer Copy control copies text; it never executes R. When clipboard permission is unavailable, the page selects the code and explains manual copying. Inspect inputs and output before using an example with real observations.

For a first numeric exercise, use explicitly constructed values:

```r
x <- c(4, 6, 8, 9, 13)
mean(x)                  # 8
median(x)                # 8
```

Both summaries are 8 for this constructed vector. That calculation does not show that a real sample is representative or that its population mean is 8.

For a research-level first task:

```r
ru_open("multiple_testing_holm")
raw_p <- c(.002, .014, .031, .20, .42, .06)
stats::p.adjust(raw_p, method = "holm")
# 0.012 0.070 0.124 0.400 0.420 0.180
```

The values are synthetic. Holm adjusts an entire prespecified family of valid raw p-values. It does not create valid raw tests, estimate an effect size, or repair selective reporting.

## Control automatic opening

Set the option **before** attachment:

```r
options(rulearn.auto_home = FALSE)
library(rulearn)
ru_home()                # Explicit request still works in supported RStudio
```

The package does not edit `.Rprofile` or permanent IDE preferences. Attachment stays quiet and does not open a browser in noninteractive R, Rscript, package checks, unsupported IDEs or RStudio child jobs. A home-opening failure must not prevent package attachment.

Outside RStudio, use explicit text or native Help:

```r
ru_text("one_sample_t")
help("research-workflows", package = "rulearn")
path <- ru_home(open = FALSE)
```

The last command prepares the same local home and returns its path invisibly. It does not launch an external browser.

## Offline operation and accessibility

Installed lessons, navigation, code copying and included base-R computations need no account, telemetry, remote model, CDN, web server or network connection. Optional source links are labelled as online references. Installing R, optional packages or a new package archive is a separate activity that can require network access.

The Viewer includes keyboard focus indicators, a skip link, named controls, image alternatives, code-scroll regions and a manual copy fallback. Headless browser checks cover narrow widths. Actual Windows RStudio keyboard, clipboard, scaling and screen-reader acceptance is not implied by those automated checks.

The package declares R 4.1 or newer. Current local execution uses R 4.5.2 on Linux. `rstudioapi` is optional and supplies IDE integration. `palmerpenguins` is optional for older dataset examples; missing optional data must produce an explicit error rather than a fabricated substitute. Other platforms and the oldest supported R version require their own recorded test results.

## Source, contribution and support boundaries

The installed instructional materials have different consumers. `inst/lessons/<id>.md`
is the source for each compact Viewer answer (including its embedded R code);
`inst/guides/<id>.qmd` holds the legacy worked walkthrough and
`inst/examples/<id>.R` its independently runnable script for `ru_code()`,
`ru_run()` and `ru_edit()`. Where a Quarto guide embeds a runnable chunk,
some guides import executable chunks from the paired R script. The two guided
activities are maintained in `inst/help-pages/tutorials.html` and assembled
into offline pages by `R/home.R`. Native help lives in `man/*.Rd`; distinct
coverage, pathways, routing and reference contracts live in `inst/extdata/`.
The five distributed SVGs in `inst/www/figures/` are reproducible through
`scripts/generate-figures.R`. `R/` provides search, rendering and compatibility
helpers. These formats serve separate teaching and package interfaces, not
interchangeable copies of a lesson. Avoid duplicating an explanation when adding
a new surface; consolidating older sources requires a tested consumer migration.

Contributions must use original or demonstrably permitted material, synthetic examples or properly sourced data, explicit assumptions and frozen positive/negative cases. A new method needs independent numerical checks. Keep private data, raw assessment material, personal paths and confidential QA evidence out of the public tree. Do not hide mandatory third-party attribution.

This library offers educational references, not live personal support, certification of an analysis, or a guarantee against scientific or legal error. Report a defect with the package version, method ID, a synthetic reproducible example, expected output and actual output. Do not include private observations or credentials.

## Verification and release status

Build from the source directory or name it explicitly from its parent:

```sh
R CMD build path/to/source
R CMD check --no-manual rulearn_0.4.2.9001.tar.gz
```

Use an isolated R library for installation and rerun every committed test against the installed archive. The original test cases remain; exact catalogue/version assertions change only when independently verified additions justify them. New tests cover method selection, numerical oracles, rejected inputs, RNG preservation and the home/attach contract.

The package is installable from public GitHub `main` using the commands above; it is not a CRAN release or standalone Windows installer. An older public tag may not contain these features. The current `LICENSE` grants MIT terms for expressly listed newly authored code and CC BY 4.0 terms for expressly listed original explanatory text, with code examples under MIT. The canonical scope is `inst/licensing/scope.csv`. Other files retain their preceding rights status. These grants do not clear redistribution of the whole archive or relicense dependencies. Do not describe the unapproved aggregate package as an open-source release.

This tree ships the local validation runner `scripts/ci-check.R`, but no tracked GitHub Actions workflow. The runner builds the package, requires a zero-note `R CMD check --no-manual`, installs the exact archive into a fresh library and reruns the committed regressions. `scripts/install-ci-deps.py` pins optional CI dependencies to versions and SHA-256 values; it is separate from the local runner. A Windows, macOS and Linux hosted matrix is not verified until a workflow and its execution evidence exist.