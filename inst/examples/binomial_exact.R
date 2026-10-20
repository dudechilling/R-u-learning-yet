# What is the chance of exactly k successes in n independent trials?
# Example source: datasets::mtcars (included with R).
library(rulearn)
d <- ru_data("mtcars")
p <- mean(d$am==1)
result <- ru_apply("binomial_exact", n=10, k=4, prob=p)
stopifnot(result>0,result<1)
