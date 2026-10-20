# How do I draw a histogram with counts, units, mean, and median?
# Independent illustrative data.
rainfall_mm <- c(0,1,1,2,3,4,4,5,6,8,9,12)
h <- hist(rainfall_mm,breaks=5,plot=FALSE)
hist(rainfall_mm,breaks=h$breaks,col="#CEE2F0",border="#244967",
     main="Rainfall observations",xlab="Rainfall (mm)",ylab="Frequency",
     ylim=c(0,max(h$counts)+3))
text(h$mids,h$counts,labels=h$counts,pos=3)
abline(v=mean(rainfall_mm),col="#215E92",lwd=2)
abline(v=median(rainfall_mm),col="#A35E20",lwd=2,lty=2)
legend("topright",legend=c("Mean","Median"),
       col=c("#215E92","#A35E20"),lty=c(1,2),bty="n")
