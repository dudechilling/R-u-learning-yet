# What is the probability of at least k successes?
# Independent illustrative data.
n <- 10; p <- 0.3; k <- 5
answer <- pbinom(k-1,size=n,prob=p,lower.tail=FALSE)
print(answer)
stopifnot(isTRUE(all.equal(answer,sum(dbinom(k:n,n,p)))))
