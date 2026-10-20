# How do I calculate an interval for an observed yes/no proportion?
# Reference dataset: datasets::mtcars (bundled with R).
library(rulearn)
d <- ru_data("mtcars")
successes <- sum(d$am==1)
fit <- ru_apply("proportion_interval", successes=successes,
                n=nrow(d), confidence=.95)
stopifnot(is.finite(fit$estimate))
