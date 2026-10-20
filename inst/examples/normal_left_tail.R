# How do I calculate the proportion below a cutoff in a normal model?
# Independent illustrative data.
mu <- 100; sigma <- 15; cutoff <- 85
answer <- pnorm(cutoff,mean=mu,sd=sigma)
print(answer)
