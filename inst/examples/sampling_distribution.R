# How do sample means vary across repeated resampling?
# Example source: datasets::iris (included with R).
library(rulearn)
d <- ru_data("iris")
means <- ru_apply("sampling_distribution", data=d,
                  x="Sepal.Length", n=30, reps=500, seed=42)
stopifnot(length(means)==500,all(is.finite(means)))
