# How do I compare the spread of one measurement across several groups?
# Dataset: datasets::iris (included with R).
library(rulearn)
d <- ru_data("iris")
medians <- ru_apply("grouped_boxplot", data=d,
                    x="Sepal.Length", group="Species")
stopifnot(length(medians)==3L)
