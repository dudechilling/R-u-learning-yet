# What is the mean and median of these five measurements?
measurements <- c(12, 13, 14, 15, 56)
average <- mean(measurements)
middle <- median(measurements)
print(average) # 22
print(middle)  # 14
stopifnot(average == 22, middle == 14)
