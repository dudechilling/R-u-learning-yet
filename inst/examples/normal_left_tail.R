# Under a normal model, what proportion falls below a cutoff?
# Example source: datasets::airquality (included with R).
library(rulearn)
d <- ru_data("airquality")
mu <- mean(d$Temp)
sigma <- sd(d$Temp)
result <- ru_apply("normal_left_tail", mu=mu, sigma=sigma,
                   threshold=75, assume_normal=TRUE)
stopifnot(result>0,result<1)
