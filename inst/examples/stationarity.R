# How do I explore whether a time series has a stable mean over time?
# Independent illustrative data.
set.seed(3)
stable <- rnorm(80,mean=8,sd=2)
trending <- stable + seq(0,12,length.out=80)
op <- par(mfrow=c(1,2))
plot(stable,type="l",col="#3F78A8",ylab="Value",
     main="Simulated stable process")
plot(trending,type="l",col="#A35E20",ylab="Value",
     main="Same noise with increasing trend")
par(op)
print(c(mean(stable[1:40]),mean(stable[41:80])))
print(c(mean(trending[1:40]),mean(trending[41:80])))
