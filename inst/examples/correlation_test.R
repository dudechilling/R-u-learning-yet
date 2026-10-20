# How do I test and interpret linear association between two measurements?
# Reference dataset: datasets::cars (bundled with R).
library(rulearn)
d <- ru_data("cars")
fit <- ru_apply("correlation_test", d, x="speed", y="dist", confidence=.95)
stopifnot(is.finite(fit$estimate))
