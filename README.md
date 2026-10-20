# R-u-learning-yet

A searchable **problem and solution bank for RStudio**. Search for the question you are trying to answer. Read the steps, see which measurements are needed, and run an independent example before applying the method to your own data.

## Search directly from the RStudio Console

Run this once to install:

```r
install.packages("remotes")
remotes::install_github("dudechilling/R-u-learning-yet")
```

Then, in any RStudio project:

```r
library(rulearn)

ru_find("show a distribution with a histogram")
ru_plan("histogram", have=c("numeric","units"), missing="groups")
ru_code("histogram")
ru_run("histogram")
```

The `ru_plan()` function makes a critical distinction: **available**, **absent**, and **unknown** information. It displays conditional steps without making up data. When prerequisites are missing, it tells you what to obtain rather than pretending the result can be calculated.

Search other questions using `ru_find("mean")`, `ru_find("outliers")`, `ru_find("p-value")`, `ru_find("CSV")`, or `ru_topics()`. Use `ru_inputs()` to see recognized input labels.

## Better plots with your own data

The bank includes base-R graph helpers:

```r
rainfall <- c(0,1,2,2,3,5,8,10,11)
ru_hist(rainfall, units="Rainfall (mm)", title="Observed rainfall")
ru_bar(c("bus","walk","bus","bike","walk"))
ru_box(c(3,4,5,6,7,9,24), units="Depth (cm)")
ru_scatter(1:6, c(3,4,7,9,9,14),
           xlab="Distance (km)", ylab="Travel time (min)")
```

These display counts, labels, reference lines, or legends as appropriate. The underlying worked scripts also show how to use `hist()`, `plot()`, `col`, `text()`, `legend()`, and `abline()` directly.

## How examples are organized

- `problems/`: searchable pages, each phrased as a question with numbered instructions, examples and limitations.
- `inst/examples/`: independent, runnable R scripts that install with the package.
- `R/`: console search, conditional routing and plot helpers.
- `inst/extdata/`: the public question index and explicit decision rules.

All examples use independently created illustrative data. They are **not** answers about your own observations, and they do not substitute for checking whether a method fits your question.

## Website

The same pages can be published as a searchable Quarto website. Website deployment is independent of the RStudio console package; the console works without a browser or live network connection after installation.

Report a reproducible error through [GitHub Issues](https://github.com/dudechilling/R-u-learning-yet/issues). See [editorial standards](methodology.md) before adding a problem.
