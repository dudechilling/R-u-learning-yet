# What is the most frequent category, including ties?
# Source dataset: datasets::mtcars, included with R.
# Follow the steps, then substitute your own table and field names.
library(rulearn)
d <- ru_data("mtcars")
answer <- ru_apply("categorical_mode", data=d, x="cyl")
stopifnot(length(answer)>=1L)
