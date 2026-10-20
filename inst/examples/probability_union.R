# How do I find the proportion where A or B happens, avoiding double-counting?
# Example source: datasets::airquality (included with R).
library(rulearn)
d <- ru_data("airquality")
result <- ru_apply("probability_union", data=d,
                   x=d$Ozone>60, y=d$Temp>=80, event=TRUE, given=TRUE)
stopifnot(result["either"]>=result["A"],result["either"]<=1)
