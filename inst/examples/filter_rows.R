# How do I keep only rows that meet a condition?
# Independent illustrative observations; replace deliberately.
d <- data.frame(id=1:5, rainfall_mm=c(1,0,7,4,10))
wet <- subset(d,rainfall_mm>=5)
print(wet)
print(nrow(wet))
