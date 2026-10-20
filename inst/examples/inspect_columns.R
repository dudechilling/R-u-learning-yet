# Which columns are numeric, categorical, or missing?
# Source dataset: datasets::airquality, included with R.
# Follow the steps, then substitute your own table and field names.
library(rulearn)
d <- ru_data("airquality")
details <- ru_apply("inspect_columns", data=d)
stopifnot(any(details$column=="Ozone"), any(details$missing>0))
