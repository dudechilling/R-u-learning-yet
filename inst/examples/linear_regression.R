# How do I fit a regression line and interpret its slope?
# Reference dataset: datasets::cars (bundled with R).
library(rulearn)
d <- ru_data("cars")
fit <- ru_apply("linear_regression", d, x="speed", y="dist")
stopifnot(inherits(fit,"lm"),is.finite(coef(fit)[2]))
