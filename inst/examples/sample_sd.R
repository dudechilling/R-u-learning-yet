# How variable are measurements, and what units does standard deviation use?
# Source dataset: datasets::iris, included with R.
# Follow the steps, then substitute your own table and field names.
library(rulearn)
d <- ru_data("iris")
answer <- ru_apply("sample_sd", data=d, x="Petal.Length")
stopifnot(answer["sample_sd"]>0,answer["n"]==150)
