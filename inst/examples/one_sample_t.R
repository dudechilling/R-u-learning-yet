# How do I test whether a sample mean differs from a reference value?
# Standalone illustrative data and R commands.
x <- c(10,12,11,15,14,13,12,16)
reference_mean <- 10
test <- t.test(x,mu=reference_mean,alternative="two.sided")
print(test$estimate)
print(test$conf.int)
print(test$p.value)
