# Which modeled value marks the pth percentile of a normal distribution?
# Example source: datasets::airquality (included with R).
library(rulearn)
d <- ru_data("airquality")
mu <- mean(d$Temp)
sigma <- sd(d$Temp)
result <- ru_apply("normal_percentile", mu=mu, sigma=sigma,
                   prob=.9, assume_normal=TRUE)
stopifnot(isTRUE(all.equal(pnorm(result,mu,sigma),.9)))
