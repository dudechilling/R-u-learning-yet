# Is the mean or median a better summary of a numeric variable?
# Source dataset: datasets::faithful, included with R.
# Follow the steps, then substitute your own table and field names.
library(rulearn)
d <- ru_data("faithful")
answer <- ru_apply("mean_median", data=d, x="waiting")
stopifnot(answer["mean"]>0,answer["median"]>0)
