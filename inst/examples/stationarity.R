# How can I explore whether a time series is reasonably stable?
# Dataset: datasets::Nile (included with R).
library(rulearn)
d <- ru_data("Nile")
check <- ru_apply("stationarity", data=d, x="flow", time="year")
stopifnot(nrow(check)==2L)
