# How do I estimate a population proportion with an interval?
# Standalone illustrative data and R commands.
successes <- 26; n <- 50
estimate <- prop.test(successes,n,conf.level=.95,correct=FALSE)
print(estimate$estimate)
print(estimate$conf.int)
