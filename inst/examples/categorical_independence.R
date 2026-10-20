# How do I test whether two categories are associated?
# Reference dataset: datasets::Titanic (bundled with R).
library(rulearn)
d <- ru_data("Titanic")
fit <- ru_apply("categorical_independence", d,
                x="Sex", y="Survived", weight="Freq")
stopifnot(!is.null(fit))
