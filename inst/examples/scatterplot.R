# How do I plot two numeric variables with a trend line and point labels?
# Independent illustrative data.
snow_cm <- c(10,15,20,25,30,40)
visitors <- c(85,91,110,125,139,168)
plot(snow_cm,visitors,type="n",xlab="Snow depth (cm)",
     ylab="Visitors",main="Illustrative paired measurements")
grid(col="gray85")
points(snow_cm,visitors,col="#3F78A8",pch=19)
fit <- lm(visitors ~ snow_cm)
abline(fit,col="#A35E20",lwd=2,lty=2)
text(snow_cm[6],visitors[6],labels="last observation",pos=2,cex=.75)
legend("topleft",legend=c("Observations","Linear fit"),
       pch=c(19,NA),lty=c(0,2),
       col=c("#3F78A8","#A35E20"),bty="n")
