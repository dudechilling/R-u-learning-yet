# How do I visualize the probability below a cutoff under a normal model?
# Dataset: datasets::iris (included with R).
library(rulearn)
d <- ru_data("iris")
mu <- mean(d$Sepal.Length)
sigma <- sd(d$Sepal.Length)
p <- ru_apply("normal_shaded_area", mu=mu, sigma=sigma,
              threshold=6, assume_normal=TRUE)
stopifnot(p>0,p<1)
