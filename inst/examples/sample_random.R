# How do I select a reproducible random sample of records?
# Example source: datasets::iris (included with R).
library(rulearn)
d <- ru_data("iris")
chosen <- ru_apply("sample_random", data=d, n=12, seed=42)
stopifnot(nrow(chosen)==12, identical(names(chosen),names(d)))
