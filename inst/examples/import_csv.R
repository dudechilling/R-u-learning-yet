# How do I load a CSV into R and check that it worked?
# Independent illustrative observations; replace deliberately.
# Example: make a temporary CSV so this script runs anywhere.
source_data <- data.frame(day=c(1,2,3), rainfall_mm=c(4,0,9))
file <- tempfile(fileext=".csv")
write.csv(source_data,file,row.names=FALSE)
d <- read.csv(file)
print(head(d))
str(d)
print(names(d))
print(nrow(d))
unlink(file)
