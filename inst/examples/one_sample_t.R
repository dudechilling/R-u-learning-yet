# How do I test whether a sample mean differs from a stated reference value?
# Reference dataset: datasets::PlantGrowth (bundled with R).
library(rulearn)
d <- ru_data("PlantGrowth")
control <- subset(d, group=="ctrl")
fit <- ru_apply("one_sample_t", control, x="weight",
                reference=5, confidence=.95)
stopifnot(is.finite(fit$p.value))
