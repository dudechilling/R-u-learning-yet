# How do I predict an outcome using a fitted regression equation?
# Standalone illustrative data and R commands.
distance_km <- c(1,2,3,4,5,6,7,8)
time_min <- c(4,6,9,11,14,16,18,21)
fit <- lm(time_min ~ distance_km)
new_case <- data.frame(distance_km=5.5)
print(predict(fit,newdata=new_case,interval="prediction"))
