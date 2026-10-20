# What cutoff marks a given percentage of a normal distribution?
# Independent illustrative data.
cutoff <- qnorm(0.9,mean=100,sd=15)
print(cutoff)
print(pnorm(cutoff,100,15))
