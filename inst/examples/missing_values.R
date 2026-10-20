# What should I do when some measurements are NA?
# Source dataset: datasets::airquality, included with R.
# Follow the steps, then substitute your own table and field names.
library(rulearn)
d <- ru_data("airquality")
answer <- ru_apply("missing_values", data=d, x="Ozone")
stopifnot(answer["missing"]>0, answer["available"]<answer["total"])
