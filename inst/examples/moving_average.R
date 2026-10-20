# How do I smooth a noisy time series with a moving average?
# Dataset: datasets::Nile (included with R).
library(rulearn)
d <- ru_data("Nile")
smoothed <- ru_apply("moving_average", data=d, x="flow",
                     time="year", window=7)
stopifnot(nrow(smoothed)==nrow(d),anyNA(smoothed$smoothed))
