# How do I assess a monotonic relationship using ranked observations?
# Reference dataset: datasets::faithful (bundled with R).
library(rulearn)
d <- ru_data("faithful")
fit <- ru_apply("spearman_correlation", d, x="eruptions", y="waiting")
stopifnot(is.finite(fit$estimate))
