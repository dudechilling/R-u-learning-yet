# How do I draw a reproducible random sample without replacement?
# Independent illustrative data.
population_ids <- 1:50
set.seed(12)
selected <- sample(population_ids,size=8,replace=FALSE)
print(selected)
stopifnot(length(selected)==8L,!anyDuplicated(selected))
