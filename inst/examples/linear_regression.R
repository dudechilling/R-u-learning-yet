# How do I fit a linear regression and explain the slope?
# Standalone illustrative data and R commands.
rain_mm <- c(1,2,3,5,6,8,10)
flow <- c(2,4,4,8,11,13,16)
fit <- lm(flow ~ rain_mm)
print(coef(fit))
print(summary(fit)$r.squared)
plot(rain_mm,flow,pch=19,col="#3F78A8",
     xlab="Rainfall (mm)",ylab="Flow index")
abline(fit,col="#A35E20",lty=2,lwd=2)
