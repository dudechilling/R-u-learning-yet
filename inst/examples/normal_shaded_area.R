# How do I shade and label a probability under a normal curve?
# Independent illustrative data.
mu <- 100; sigma <- 15; cutoff <- 85
p <- pnorm(cutoff,mean=mu,sd=sigma)
curve(dnorm(x,mu,sigma),from=40,to=160,lwd=2,col="#3F78A8",
      xlab="Value",ylab="Density",main="Normal probability to the left")
xs <- seq(40,cutoff,length.out=150)
polygon(c(40,xs,cutoff),c(0,dnorm(xs,mu,sigma),0),
        col="#CEE2F0",border=NA)
abline(v=cutoff,col="#A35E20",lty=2,lwd=2)
legend("topright",legend=paste0("P(X <= 85) = ",round(p,3)),
       fill="#CEE2F0",bty="n")
print(p)
