# What is the probability of event A given event B?
# Example source: datasets::airquality (included with R).
library(rulearn)
d <- ru_data("airquality")
A <- d$Ozone > 60
B <- d$Temp >= 80
result <- ru_apply("conditional_probability", data=d, x=A, y=B,
                   event=TRUE, given=TRUE)
stopifnot(result["probability"]>=0,result["probability"]<=1)
