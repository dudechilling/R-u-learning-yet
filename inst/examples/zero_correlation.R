# Can a correlation statistic miss a strong nonlinear relationship?
# Dataset: datasets::anscombe (included with R).
library(rulearn)
d <- ru_data("anscombe")
# Anscombe's real x2 values; the square is a NEW, constructed response.
constructed <- data.frame(deviation=d$x2-mean(d$x2))
constructed$squared <- constructed$deviation^2
r <- ru_apply("zero_correlation", data=constructed,
              x="deviation", y="squared")
stopifnot(abs(r)<1e-10)
# Compare with one of the original Anscombe pairs:
ru_apply("zero_correlation", data=d, x="x2", y="y2")
