# What is the chance of at least k successes in n trials?
# Example source: datasets::mtcars (included with R).
library(rulearn)
d <- ru_data("mtcars")
p <- mean(d$am==1)
result <- ru_apply("binomial_at_least", n=10, k=5, prob=p)
stopifnot(isTRUE(all.equal(result, pbinom(4,10,p,lower.tail=FALSE))))
