# How many standard deviations is a specified value from the sample mean?
# Source dataset: datasets::iris, included with R.
# Follow the steps, then substitute your own table and field names.
library(rulearn)
d <- ru_data("iris")
answer <- ru_apply("z_score", data=d, x="Sepal.Length", threshold=7)
stopifnot(length(answer)==1L,is.finite(answer))
