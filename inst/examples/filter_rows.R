# How do I select rows that meet a condition?
# Source dataset: datasets::mtcars, included with R.
# Follow the steps, then substitute your own table and field names.
library(rulearn)
d <- ru_data("mtcars")
efficient <- ru_apply("filter_rows", data=d, x="mpg",
                      operator=">=", threshold=25)
stopifnot(all(efficient$mpg>=25),nrow(efficient)<nrow(d))
