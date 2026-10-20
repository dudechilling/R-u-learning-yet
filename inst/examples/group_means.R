# How do I compare average values across categories?
# Source dataset: datasets::iris, included with R.
# Follow the steps, then substitute your own table and field names.
library(rulearn)
d <- ru_data("iris")
answer <- ru_apply("group_means", data=d,
                   x="Sepal.Length", group="Species")
stopifnot(nrow(answer)==3, all(answer$n==50))
