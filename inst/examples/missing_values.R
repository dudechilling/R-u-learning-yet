# How many measurements are missing and how do I exclude them from a mean?
# Independent illustrative observations; replace deliberately.
x <- c(8,12,NA,14,16,NA)
print(sum(is.na(x)))
print(sum(!is.na(x)))
print(mean(x,na.rm=TRUE))
