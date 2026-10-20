# How do I estimate a value between two recorded x positions?
# Reference dataset: datasets::Nile (bundled with R).
library(rulearn)
d <- ru_data("Nile")
estimate <- ru_apply("interpolation", d, x="year", y="flow",
                     threshold=1900.5)
stopifnot(is.finite(estimate$y))
