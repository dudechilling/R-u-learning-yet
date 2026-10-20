# How can I estimate uncertainty in a sample mean?
# Reference dataset: datasets::iris (bundled with R).
library(rulearn)
d <- ru_data("iris")
result <- ru_apply("standard_error", d, x="Sepal.Length")
stopifnot(result["estimated_se"]>0,result["n"]==150)
