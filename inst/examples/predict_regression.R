# How do I predict a new observation from a fitted regression?
# Reference dataset: datasets::cars (bundled with R).
library(rulearn)
d <- ru_data("cars")
prediction <- ru_apply("predict_regression", d, x="speed", y="dist",
                       new_x=15.5, confidence=.95)
stopifnot(nrow(prediction)==1L,all(is.finite(prediction)))
