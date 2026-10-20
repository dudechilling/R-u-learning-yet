# How do I draw a boxplot and identify potential outliers?
# Independent illustrative data.
x <- c(3,4,5,5,6,6,7,7,8,8,9,31)
boxplot(x,col="#CEE2F0",border="#244967",ylab="Depth (cm)",
        main="Distribution of depths")
s <- boxplot.stats(x)
print(s$out)
legend("topright",legend=paste("Median =",median(x)),bty="n")
