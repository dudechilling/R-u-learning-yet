# How do I simulate a sampling distribution of means?
# Independent illustrative data.
set.seed(42)
means <- replicate(1000,mean(rexp(30,rate=1/5)))
h <- hist(means,breaks=25,col="#CEE2F0",border="#244967",
          xlab="Sample mean",main="Repeated means of skewed data")
abline(v=5,col="#A35E20",lwd=2,lty=2)
legend("topright",legend="Model mean = 5",lty=2,col="#A35E20",bty="n")
print(c(mean_of_means=mean(means),sd_of_means=sd(means)))
