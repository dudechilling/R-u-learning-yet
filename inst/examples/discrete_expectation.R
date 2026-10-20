# How do I calculate a weighted expected value from discrete outcomes?
# Example source: datasets::mtcars (included with R).
library(rulearn)
d <- ru_data("mtcars")
counts <- table(d$cyl)
outcomes <- as.numeric(names(counts))
weights <- as.numeric(prop.table(counts))
answer <- ru_apply("discrete_expectation", x=outcomes, y=weights)
stopifnot(isTRUE(all.equal(unname(answer["expected"]),mean(d$cyl))))
