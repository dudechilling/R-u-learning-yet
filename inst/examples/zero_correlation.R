# If Pearson correlation is zero, does that mean there is no relationship?
# Independent illustrative data.
x <- -3:3
y <- x^2
print(cor(x,y))
plot(x,y,pch=19,col="#3F78A8",xlab="X",ylab="Y",
     main="Zero linear correlation, clear curved pattern")
curve(x^2,from=-3,to=3,add=TRUE,col="#A35E20",lwd=2)
legend("top",legend=c("Observed pairs","Curved pattern"),
       pch=c(19,NA),lty=c(0,1),
       col=c("#3F78A8","#A35E20"),bty="n")
