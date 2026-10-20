# What is the chance of exactly k successes in n independent trials?
# Independent illustrative data.
n <- 10; p <- 0.3; k <- 3
answer <- dbinom(k,size=n,prob=p)
print(answer)
