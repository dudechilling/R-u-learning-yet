# What observed value corresponds to a requested percentile?
# Source dataset: datasets::quakes, included with R.
# Follow the steps, then substitute your own table and field names.
library(rulearn)
d <- ru_data("quakes")
answer <- ru_apply("percentile_cutoff", data=d, x="mag", prob=.75)
stopifnot(is.finite(answer),answer>=min(d$mag),answer<=max(d$mag))
