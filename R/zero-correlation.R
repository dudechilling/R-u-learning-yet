# Does Pearson r = 0 rule out a curved relationship?
x <- -3:3
y <- x^2
plot(x, y, pch = 19, xlab = "X", ylab = "Y")
r <- cor(x, y)
print(r) # 0 (up to floating-point precision)
stopifnot(abs(r) < 1e-12)
