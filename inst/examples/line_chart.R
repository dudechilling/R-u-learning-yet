# How do I display measurements across ordered time points?
# Dataset: datasets::Nile (included with R).
library(rulearn)
d <- ru_data("Nile")
timeline <- ru_apply("line_chart", data=d, x="flow", time="year")
stopifnot(nrow(timeline)==nrow(d))
