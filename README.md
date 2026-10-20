# R-u-learning-yet

**An offline reference library for learning statistics and R in RStudio.**

Start with a question, not a function name. Find a definition, consult R's native help, read a practical walkthrough, then write and modify ordinary R code. You do **not** need to use a custom calculation wrapper to work through a problem.

## Release status

These reference-library changes are currently **local development work**. The public
GitHub `main` branch does not yet contain them. Until an authorized review and
merge, the GitHub installation command below installs the older release.

To test an approved local checkout, run `R CMD INSTALL .` in a terminal from
the repository root, then load `library(rulearn)` in RStudio.

## Install from GitHub after release

```r
install.packages("remotes") # only needed once for installation
remotes::install_github("dudechilling/R-u-learning-yet")
library(rulearn)

ru_find("What is stationarity?")
ru_find("Define standard deviation")
ru_find("What does a p-value mean?")
ru_find("How do I make a histogram?")
ru_find("How does the sd function work?")
ru_find("What is a sample space?")
ru_find("Stem and leaf plot")
```

Search results distinguish **Concept**, **Function**, and **Walkthrough**, and provide the direct command to open each entry. Search is deterministic and runs locally after installation. No chatbot or live service is involved.

## 1. Understand a concept

```r
help("stationarity", package="rulearn")
ru_open("stationarity")
help("standard_deviation", package="rulearn")
```

The reference articles open in R's usual Help system, including RStudio's Help pane. They explain a definition, its meaning, a practical example, important distinctions, limitations, relevant R code and related concepts. Use `??stationarity` to search installed R help more broadly.

## 2. Learn the R function

```r
ru_find("How does the sd function work?", type="function")
ru_open("sd")                      # beginner-friendly function reference
help("sd", package="stats")       # official R function documentation
?sd                                  # R's ordinary help shortcut
```

R's own help remains the authoritative reference for syntax and supported arguments.

## 3. Follow a worked problem and edit the code

```r
ru_find("How do I customize a histogram?", type="walkthrough")
ru_guide("histogram")   # read the complete guide offline
ru_code("histogram")    # print ordinary R commands
ru_edit("histogram", mode="quick")   # only the immediate, editable answer
ru_edit("histogram")                 # detailed, editable walkthrough
```

The histogram example uses `faithful` and teaches `hist()`, `breaks`, `col`, `main`, `xlab`, `ylab`, `text()`, `abline()`, and `legend()` without requiring `ru_apply()`. Change `faithful$eruptions` to a suitable numerical column in your own data, then run one line at a time using **Ctrl+Enter**.

Two other fully annotated examples demonstrate grouped boxplots with `iris` and a Welch two-sample t-test with `PlantGrowth`.

## Reference collection

The package currently contains **20 concept references**, **10 beginner-oriented function references**, and **46 existing question-led walkthroughs**. Four fully revised examples set the standard for improving the remaining walkthroughs; the others remain available for use and future revision.

- **Concepts:** population and sample; center and spread; probability and sampling distributions; correlation and autocorrelation; stationarity, trend and seasonality; inference, intervals and study design.
- **Functions:** `mean()`, `median()`, `sd()`, `hist()`, `quantile()`, `cor()`, `t.test()`, `acf()`, and `table()`.
- **Walkthroughs:** browse [the question-led index](inst/guides/index.qmd), or search from the RStudio console.

The source of a concept or function reference is its native [R help file](man/). The longer tutorials remain in [`inst/guides/`](inst/guides/); their scripts are in [`inst/examples/`](inst/examples/). These are different types of content, not independent copies of an article.

## Using authentic datasets

R already includes `iris`, `faithful`, `airquality`, `mtcars`, `PlantGrowth`, `sleep`, `Nile`, `Titanic` and other relevant datasets.

```r
data(iris)
names(iris)
mean(iris$Sepal.Length)
hist(iris$Sepal.Length,
     xlab="Sepal length (cm)", main="Recorded flowers")
```

Optional Palmer penguins data require a separately installed `palmerpenguins` package. Hypothetical model inputs and constructed variables are labeled as such. The data remain in their respective source packages; they are not copied into this repository.

## Compatibility and limitations

The older `ru_apply()`, `ru_plan()`, `ru_run()` and plotting helpers remain available for existing users. They are not the primary learning path. Method-specific options that were previously ignored now produce clear errors when unsupported; frequency-weighted probabilities and statistical test alternatives have been corrected. Conventional autocorrelation rejects irregular timestamps.

The existing Quarto site is for longer walkthroughs. Concepts and function references are also available offline through native R help and do not require Quarto. The website is not required to use the installed reference library.

See the [competitive research and decision record](research-and-decision.md) for verified capabilities, alternative products, evidence limits, and the learner-testing protocol.

See [editorial and verification rules](methodology.md). Source redistribution rights have not been changed.