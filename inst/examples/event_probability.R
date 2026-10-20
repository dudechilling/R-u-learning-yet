# What fraction of recorded observations meets a condition?
# Example source: datasets::airquality (included with R).
library(rulearn)
d <- ru_data("airquality")
event <- d$Ozone > 60
result <- ru_apply("event_probability", data=d, x=event, event=TRUE)
stopifnot(result["events"]<=result["trials"])
