# How do I display the distribution of numerical observations?
# Dataset: datasets::faithful (included with R).
library(rulearn)
d <- ru_data("faithful")
h <- ru_apply("histogram", data=d, x="eruptions")
stopifnot(sum(h$counts)==nrow(d))
