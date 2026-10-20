# How do I get quartiles, an IQR, and a five-number summary?
# Source dataset: datasets::mtcars, included with R.
# Follow the steps, then substitute your own table and field names.
library(rulearn)
d <- ru_data("mtcars")
answer <- ru_apply("five_number", data=d, x="mpg")
stopifnot(answer$IQR>0, length(answer$quantile)==5)
