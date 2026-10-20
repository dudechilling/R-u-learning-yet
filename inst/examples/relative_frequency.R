# How do I convert observations into percentages by category?
# Source dataset: datasets::mtcars, included with R.
# Follow the steps, then substitute your own table and field names.
library(rulearn)
d <- ru_data("mtcars")
answer <- ru_apply("relative_frequency", data=d, x="cyl")
stopifnot(isTRUE(all.equal(sum(answer$proportion),1)))
