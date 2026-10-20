# How far is one value from the sample mean in standard deviations?
# Independent illustrative observations; replace deliberately.
x <- c(10,12,14,16,18)
chosen <- 18
s <- sd(x)
if (s==0) stop("No variation: z-score is undefined.")
z <- (chosen-mean(x))/s
print(z)
