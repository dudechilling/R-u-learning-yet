# How do I calculate the standard error of a sample mean?
# Standalone illustrative data and R commands.
x <- c(11,12,14,16,17,18,19,21)
n <- length(x)
se <- sd(x)/sqrt(n)
print(c(n=n,mean=mean(x),sample_sd=sd(x),SE=se))
