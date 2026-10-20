# How do I calculate a confidence interval for a population mean?
# Standalone illustrative data and R commands.
x <- c(11,12,14,15,17,18,19,20)
estimate <- t.test(x,conf.level=.95)
print(estimate$estimate)
print(estimate$conf.int)
