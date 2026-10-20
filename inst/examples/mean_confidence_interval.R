# How do I estimate a confidence interval for a population mean?
# Reference dataset: datasets::PlantGrowth (bundled with R).
library(rulearn)
d <- ru_data("PlantGrowth")
control <- subset(d, group=="ctrl")
fit <- ru_apply("mean_confidence_interval", control,
                x="weight", confidence=.95)
stopifnot(length(fit$conf.int)==2L)
