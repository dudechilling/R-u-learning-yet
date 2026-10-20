# How do I import a CSV and confirm the fields were read correctly?
# Source dataset: datasets::iris, included with R.
# Follow the steps, then substitute your own table and field names.
library(rulearn)
d <- ru_data("iris")
csv <- tempfile(fileext=".csv")
write.csv(d, csv, row.names=FALSE)
imported <- ru_apply("import_csv", file=csv)
stopifnot(nrow(imported)==150L, identical(names(imported),names(d)))
unlink(csv)
