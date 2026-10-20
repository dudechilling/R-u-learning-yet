# How do I plot paired numeric variables and show a fitted line?
# Dataset: datasets::cars (included with R).
library(rulearn)
d <- ru_data("cars")
fit <- ru_apply("scatterplot", data=d, x="speed", y="dist")
stopifnot(inherits(fit,"lm"))
