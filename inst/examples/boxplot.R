# How do I show the median, quartiles, and potential outliers?
# Dataset: datasets::airquality (included with R).
library(rulearn)
d <- ru_data("airquality")
s <- ru_apply("boxplot", data=d, x="Ozone")
stopifnot(length(s$stats)==5L)
