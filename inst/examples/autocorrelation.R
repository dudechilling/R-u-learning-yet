# How do I check whether consecutive observations are related?
# Dataset: datasets::Nile (included with R).
library(rulearn)
d <- ru_data("Nile")
lags <- ru_apply("autocorrelation", data=d, x="flow", time="year")
stopifnot(inherits(lags,"acf"))
