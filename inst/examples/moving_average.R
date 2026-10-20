# How do I smooth noisy measurements with a moving average?
# Independent illustrative data.
days <- 1:12
x <- c(4,8,5,10,7,12,11,15,14,18,16,19)
smooth <- as.numeric(stats::filter(x,rep(1/3,3),sides=2))
plot(days,x,type="b",pch=19,col="#3F78A8",
     xlab="Day",ylab="Measurement",
     main="Original values and 3-day moving average")
lines(days,smooth,col="#A35E20",lwd=3)
legend("topleft",legend=c("Raw","3-day mean"),
       col=c("#3F78A8","#A35E20"),lty=1,lwd=c(1,3),bty="n")
