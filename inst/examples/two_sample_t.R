# How do I compare two independent groups using a t test?
# Reference dataset: datasets::PlantGrowth (bundled with R).
library(rulearn)
d <- ru_data("PlantGrowth")
two <- subset(d, group %in% c("ctrl","trt1"))
fit <- ru_apply("two_sample_t", two,
                x="weight", group="group", independent=TRUE, confidence=.95)
stopifnot(is.finite(fit$p.value))
