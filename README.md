# R-u-learning-yet

A searchable, question-first collection of RStudio solutions. Each worked problem uses a **real, named dataset** where that makes sense, shows how the method works, and gives an equivalent call for **your own data and columns**.

Search from the RStudio **Console**. No browser or internet access is needed after installing the package.

## Install once

```r
install.packages("remotes")
remotes::install_github("dudechilling/R-u-learning-yet")
library(rulearn)
```

## Find the right method

```r
ru_find("How can I show the distribution and mark the mean?")
ru_find("Do two groups have different means?")
ru_find("Does a zero correlation mean no relationship?")
ru_topics()
ru_plan("histogram")
```

A problem plan separates **available**, **explicitly missing**, and **unknown** information:

```r
ru_plan("histogram", have=c("numeric", "units"), missing="groups")
ru_code("histogram")
ru_run("histogram")
```

`ru_code()` prints the example script; `ru_run()` executes it in a separate environment. These commands do **not** operate on your open dataset or insert invented values into it.

## Practice on named datasets

```r
ru_datasets()
flowers <- ru_data("iris")
ru_columns(flowers)

ru_apply("mean_median", data=flowers, x="Sepal.Length")
ru_apply("group_means", data=flowers, x="Sepal.Length", group="Species")
ru_apply("histogram", data=flowers, x="Petal.Length")
ru_apply("grouped_boxplot", data=flowers, x="Sepal.Length", group="Species")
```

Other included-R datasets cover missing values (`airquality`), speed and stopping distance (`cars`), fuel economy (`mtcars`), time series (`Nile` and `AirPassengers`), historical frequency tables (`Titanic`), and paired observations (`sleep`). **The underlying tables remain in R; the repository does not duplicate their raw data.**

Palmer penguins is optional, not an automatic download:

```r
install.packages("palmerpenguins")  # only if you want penguin examples
penguins <- ru_data("penguins")
ru_columns(penguins)
ru_apply("grouped_boxplot", data=penguins,
         x="body_mass_g", group="species")
ru_apply("scatterplot", data=penguins,
         x="bill_length_mm", y="bill_depth_mm")
```

Palmer penguins' source data are distributed under CC0. Some fields have missing observations; the functions disclose omitted measurements.

## Use the same methods with your own file

```r
mine <- read.csv("measurements.csv")
ru_columns(mine)
ru_find("quartiles")
ru_apply("five_number", data=mine, x="your_numeric_column")
ru_apply("scatterplot", data=mine,
         x="your_predictor_column", y="your_outcome_column")
```

The column names above are placeholders that you replace after checking `ru_columns(mine)`. The library does **not** infer your variables, their units, or the sampling design.

Frequency tables require special care. A row with `Freq=100` represents 100 observations, not one:

```r
ship <- ru_data("Titanic")
ru_apply("relative_frequency", ship, x="Survived", weight="Freq")
ru_apply("bar_chart", ship, x="Survived", weight="Freq")
```

## Choosing a method is not validating its assumptions

- A histogram, boxplot or mean describes the recorded values. It does not establish population representativeness.
- Two-sample and paired tests require a defensible study design. Mark independence or pairing explicitly when applying them.
- A normal curve is a **model assumption**, not a property automatically established by an observed sample.
- The empirical bootstrap describes resampling from available observations. It does not correct a biased sample.
- Missing measurements, unknown units, model fit and time spacing can change the meaning of a result.

The repository includes **46 question-led guides** in [`problems/`](problems/index.qmd), with runnable scripts in [`inst/examples/`](inst/examples/). Those guides explain method choice, RStudio steps, interpretation and important exceptions. The search system is an inspectable keyword index and conditional decision rules—not a language model.

## Development and verification

This is an R package built around base R, with optional penguin data. To test a local copy, use `R CMD build` and `R CMD check --no-manual`, or install it and run the included smoke and dataset-adaptation tests.

Source and editorial rules are in [methodology.md](methodology.md). A searchable Quarto website is configured, but its deployment is separate from the working RStudio console interface.
