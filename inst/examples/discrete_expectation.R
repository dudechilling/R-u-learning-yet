# How do I calculate the expected value of a discrete probability distribution?
# Independent illustrative data.
outcomes <- 0:3
p <- c(0.2,0.4,0.3,0.1)
stopifnot(all(p>=0),isTRUE(all.equal(sum(p),1)))
expectation <- sum(outcomes*p)
variance <- sum((outcomes-expectation)^2*p)
print(c(expected=expectation,variance=variance))
