# How do I estimate a value between two known measurements?
# Standalone illustrative data and R commands.
time <- c(0,5,10,15)
temperature <- c(10,16,22,21)
target <- 7.5
stopifnot(target>=min(time),target<=max(time))
print(approx(time,temperature,xout=target))
plot(time,temperature,type="b",pch=19,col="#3F78A8",
     xlab="Minutes",ylab="Temperature (C)")
points(target,approx(time,temperature,xout=target)$y,
       col="#A35E20",pch=19,cex=1.5)
