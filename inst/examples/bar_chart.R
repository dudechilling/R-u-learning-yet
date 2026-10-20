# How do I display and label the frequency of categories?
# Dataset: datasets::iris (included with R).
library(rulearn)
d <- ru_data("iris")
counts <- ru_apply("bar_chart", data=d, x="Species")
stopifnot(sum(counts)==nrow(d))
